# DISCO Dashboard

A management dashboard for the DISCO, cluster orchestration framework.

Implemented in Ruby on Rails 5.0

## Getting started

*if you don't have Ruby 2.3.1 and Rails 5.0 installed, please follow this [link](Installation_guide.md)*

To get started with the app, clone the repo and then install the needed gems:

```
$ bundle install --without production
```

Execute figaro gem:

```
bundle exec figaro
```

Set up environment variables in *config/application.yml*:

```
development:
  disco_ip: 'http://xxx.xxx.xxx.xxx:port/haas/'
  fingerprint: "b2:c1:f1:50:e3:f8:7b:88:fa:e3:b1:97:a5:6b:32:27"
  region: 'LS'
```


Next, migrate the database:

```
$ rails db:migrate
```

Finally, run the test suite to verify that everything is working correctly:

```
$ rails test
```

If the test suite passes, you'll be ready to run the app in a local server:

```
$ rails server
```

Run 'sidekiq' on another window/terminal, but from the main directory of the application:

```
$ bundle exec sidekiq
```


You will need a redis-server for Action Cable and Sidekiq(background jobs)support.
Redis server is configured to the default port 6379.
