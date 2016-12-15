*More apprehensive guide and MacOS installation can be found [here](http://railsapps.github.io/installing-rails.html)*

# Installing Ruby and Rails 5.0 on Linux/Ubuntu

## Ruby 2.3.x

```
$ sudo apt-get install ruby
```

## Rails 5.0.1

### Check the Gem Manager

```
$ gem -v
2.3.1
```

Just in case:
```
$ sudo gem update --system
$ sudo gem update
```

### Install Bundler

```
$ sudo gem install bundler
```

### Install Nokogiri

```
$ sudo gem install nokogiri
```

If you have issues, first make sure you have all the tooling necessary to compile C extensions:
```
$ sudo apt-get install build-essential patch
```

It’s possible that you don’t have important development header files installed on your system:
```
$ sudo apt-get install ruby-dev zlib1g-dev liblzma-dev
```

### Install Rails

```
$ sudo gem install rails
```

Rails should be set up at this point. If you have issues, you can follow the link above or email me "kenz[at]zhaw.ch".
