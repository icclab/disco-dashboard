# DISCO Dashboard

A management dashboard for the DISCO, cluster orchestration framework.

Implemented in Ruby on Rails 5.0

## Getting started

*if you don't have Ruby 2.3.1 and Rails 5.0 installed, please follow this [link](Installation_guide.md)*

To get started with the app, clone the repo and then install the needed gems:

```
$ bundle install --without production
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

You will need a redis-server for Action Cable support.
Redis server is configured to the default port 6379.
