# DISCO Dashboard

A management dashboard for the [DISCO](https://github.com/icclab/disco), cluster orchestration framework.

Implemented in Ruby on Rails 5.0.1.
Background job is handled by Sidekiq.
Message/work qeueuing is handled by Redis. 

Requirements:
     [Ruby Version Manager (RVM)](https://rvm.io/)
    - [Ruby 2.3.1](https://www.ruby-lang.org/en/documentation/)
    - [Rails 5.0.1](http://rubyonrails.org/)
    - [Bundler](http://bundler.io/)
    - [Nokogiri](http://www.nokogiri.org/) 
    - [NodeJS](https://nodejs.org/en/)
    - [Redis](https://redis.io/)

## Getting started (development mode)
#### *currently runs only in a development mode*


*To configure your whole system for the application, please follow this [link](setup_guide.md)*

Before everything, to be sure, source RVM:
```
source /home/$USER/.rvm/scripts/rvm
```

(Optional) Before running the application to fill the database with a fake data run:
```
$ rails db:seed
```

To run the application you need to do following steps.
On a different terminal or screen, but from the same directory run [sidekiq](https://github.com/mperham/sidekiq):
```
$ bundle exec sidekiq
```
It will handle all background jobs.

Also, make sure that redis-server is also running. To run redis-server use following command on a separate terminal or screen:
```
$ redis-server
```
It's needed for ActionCable and Sidekiq support. In the app redis server is configured to the default port 6379.

Finally, to run the app in a local server(will run on localhost):
```
$ rails server
```
Or from remote server you also need to bind it to the IP address (e.g. VM on cloud):
```
$ rails server -b "server_ip" -p "port"
```
"server_ip" is a local ip, not a floating ip if server is running on Cloud VM, however should be accessed using a floating ip. And make sure that specified port is open. 
*Rails will run on port '3000' by default, if port is not specified.*


If you have issues or questions, please, feel free to contact by email "kenz[at]zhaw.ch".
