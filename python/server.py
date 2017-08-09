from flask import Flask, request
from flask_restful import Resource, Api
from sqlalchemy import create_engine
import threading
import Queue
from keystoneclient.v2_0 import client as keystoneclient
import urllib2
import json
import socket
from threading import Thread
import time
from configobj import ConfigObj
config = ConfigObj("./config.conf")


db_connect = create_engine(config['dbfile'])
app = Flask(__name__)
api = Api(app)

# the main queue for every cluster inserted
worker_queue = Queue.Queue()

# interval in seconds; was 3 in the Ruby script
INTERVAL = 2

class cluster_entry:
    '''
    cluster_entry is an element representing a cluster which can handle the
    request to the DISCO backend itself
    '''
    def __init__(self, disco_url, infrastructure_id, user_id, cluster_id, password):
        '''
        the relevant information to query the DISCO backend is provided in the
        constructor
        :param disco_url: URL of the DISCO backend
        :param infrastructure_id: the dashboard's infrastructure ID
        :param user_id: the dashboard's user ID
        :param cluster_id: the dashboard's cluster ID
        :param password: OpenStack password of the deploying OpenStack user
        '''
        self.disco_url = disco_url
        self.infrastructure_id = infrastructure_id
        self.user_id = user_id
        self.cluster_id = cluster_id
        self.password = password

        # Is the entry initialised yet? This is shifted to to be executed
        # within its own thread as it might take some time
        self.setup = False

        # Variable indicating whether this cluster has been queried success-
        # fully until its final state
        self.finished = False

        # in case of a timeout or error, this variable is set accordingly
        self.timeout = 0

    def process(self):
        '''
        process handles the connection to the DISCO backend and data retrieval
        :return:
        '''
        conn = db_connect.connect()
        if not self.setup:
            # initialise local elements from database
            query = conn.execute("SELECT * from infrastructures where id='%s'" % self.infrastructure_id)
            vals = query.first()
            keys = query.keys()

            # OpenStack login data; needed for token creation for backend
            self.auth_url = vals[keys.index("auth_url")]
            self.username = vals[keys.index("username")]
            self.tenant = vals[keys.index("tenant")]
            self.region = vals[keys.index("region")]

            # get DISCO backend's cluster UUID
            # conn = db_connect.connect()
            query = conn.execute("SELECT uuid from clusters where id='%s'" % self.cluster_id)
            self.cluster_uuid = query.first()[0]

            self.setup = True

        # query the DISCO backend
        disco_entry = self.get_disco_entry()

        # process the backend's response
        if disco_entry != None:
            if "attributes" in disco_entry and "stack_status" in disco_entry["attributes"]:
                self.stack_status = disco_entry['attributes']['stack_status']
                if self.stack_status=='CREATE_COMPLETE':
                    self.ssh_private_key = disco_entry['attributes']['ssh_private_key']
                    self.external_ip = disco_entry['attributes']['external_ip']
                    ip_split = self.external_ip.split('.')
                    ip_num = ((int(ip_split[0])*256+int(ip_split[1]))*256+int(ip_split[2]))*256+int(ip_split[3])
                    # conn = db_connect.connect()
                    conn.execute("UPDATE clusters SET state='%s', external_ip='%d', ssh_private_key='%s' WHERE id='%s'" % (self.stack_status, ip_num, self.ssh_private_key, self.cluster_id))
                    self.finished = True
                    print("cluster %s finished successfully" % self.cluster_id)
                elif self.stack_status=='CREATE_FAILED':
                    # conn = db_connect.connect()
                    disco_status_msg = disco_entry['attributes']['stack_status_reason'] # .replace("'","\\'").replace("\"","\\\"")
                    conn.execute("UPDATE clusters SET state=?, status=? WHERE id=?", (self.stack_status, disco_status_msg, self.cluster_id))
                    self.finished = True
                    print("cluster %s finished with CREATE_FAILED" % self.cluster_id)
                else:
                    # conn = db_connect.connect()
                    conn.execute("UPDATE clusters SET state='%s' WHERE id='%s'" % (self.stack_status, self.cluster_id))
                    print("neither CREATE_COMPLETE nor CREATE_FAILED for cluster %s" % self.cluster_id)
            else:
                print("no processable result for cluster %s yet" % self.cluster_id)

        # timeout is set within method get_disco_entry() and evaluated here
        if self.timeout>5:
            # timeout number is an arbitrary setting
            # conn = db_connect.connect()
            conn.execute("UPDATE clusters SET state='TIMEOUT' WHERE id='%s'" % self.cluster_id)
            self.finished = True
            print("timeout %s for cluster %s" % (self.timeout, self.cluster_id))
        elif self.timeout==-1:
            # -1 means general exception while querying the backend; e.g. not
            # found
            # conn = db_connect.connect()
            conn.execute("UPDATE clusters SET state='NOT_FOUND' WHERE id='%s'" % self.cluster_id)
            self.finished = True
            print("general exception for cluster %s" % self.cluster_id)


    def get_disco_entry(self):
        '''
        A query is issued to the DISCO backend which will contain the cluster's
        current status, the cluster's output values, etc.

        The type of request to be issued:
        curl -v -X GET http://127.0.0.1:8888/disco/$UUID -H 'Category: disco; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";' -H 'Content-type: text/occi' -H 'X-Tenant-Name: tenantname' -H "X-Auth-Token: $TOKEN"
        :return:
        '''
        self.token = self.get_token()
        url = "%s%s" % (self.disco_url,self.cluster_uuid)
        req = urllib2.Request(url)

        # set the according headers for the backend
        req.add_header('Category', 'disco; scheme="http://schemas.cloudcomplab.ch/occi/sm#"; class="kind";')
        req.add_header('Content-Type', 'text/occi')
        req.add_header('X-Tenant-Name', str(self.tenant))
        req.add_header('X-Auth-Token', str(self.token))
        req.add_header('Accept', 'application/occi+json')

        # handle the reply:
        content = None
        try:
            resp = urllib2.urlopen(req, timeout=30)
            self.timeout = 0
            jsoncontent = resp.read()
            if resp.code == 200:
                content = json.loads(jsoncontent)
            else:
                raise Exception
        except socket.timeout:
            self.timeout += 1
        except Exception as e:
            self.timeout = -1

        return content

    def get_token(self):
        '''
        query OpenStack for a token (needed for the backend communication)
        :return:
        '''
        kc = keystoneclient.Client(auth_url=self.auth_url,
                                   username=self.username,
                                   password=self.password,
                                   tenant_name=self.tenant
                                   )
        return kc.auth_token

    def is_finished(self):
        '''
        returns whether this entry has already finished its processing; could
        be a more complex result as well with conditionals
        :return:
        '''
        return self.finished

def BackgroundWork():
    '''
    BackgroundWork is the main program loop which is executing the requests
    until the cluster has been deployed or until deployment has failed
    '''
    while True:
        # the while loop is partitioned in 3 stages
        time.sleep(INTERVAL)
        # TODO: implement waiting differently: issue a blocking get call on the worker_queue as that will certainly not use any CPU cycles while still responding immediately to new entries; take into account in this case: if elements are within the queue, there should be a sleeping period between two calls

        # setting up the queues at every iteration ensures a clean queue
        thread_queue = Queue.Queue()
        temp_queue = Queue.Queue()

        # 1st stage: insert not finished elements into temporary queue
        while not worker_queue.empty():
            cur_element = worker_queue.get()
            if not cur_element.is_finished():
                temp_queue.put(cur_element)

        # 2nd stage: in order to save time, every cluster query is started
        # in its own thread; the thread handle is inserted into an extra queue
        while not temp_queue.empty():
            cur_element = temp_queue.get()
            thread_handle = Thread(target=cur_element.process)
            thread_handle.start()
            thread_queue.put(thread_handle)
            worker_queue.put(cur_element)

        # 3rd stage: waiting until each thread has completed
        while not thread_queue.empty():
            cur_thread = thread_queue.get()
            cur_thread.join()

class Cluster(Resource):
    '''
    Cluster is the Flask class handling the webserver communication
    '''
    def get(self, infrastructure_id, user_id, cluster_id):
        '''
        the function for inserting another cluster to be queried for its output
        values
        :param infrastructure_id: dashboard ID of the infrastructure
        :param user_id: dashboard ID of the querying user
        :param cluster_id: dashboard ID of the requested infrastructure
        :return: "ayos" for the successful completion of insertion
        '''
        disco_url = request.headers.get("disco_url")
        password = request.headers.get("password")
        new_cluster = cluster_entry(disco_url, infrastructure_id, user_id, cluster_id, password)
        worker_queue.put(new_cluster)
        print("added cluster %s for user %s on infrastructure %s to the queue" % (cluster_id, user_id, infrastructure_id))
        return "ayos"


api.add_resource(Cluster, '/newcluster/<infrastructure_id>/<user_id>/<cluster_id>')  # Route_3

if __name__ == '__main__':
    t = threading.Thread(target=BackgroundWork)
    t.setDaemon(True)
    t.start()
    app.run(port='5002')
