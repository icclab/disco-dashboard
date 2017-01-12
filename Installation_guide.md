# Installation guide for DISCO Dashboard dependencies

## Option #1 (Manual) *recommended*

*More apprehensive guide and MacOS installation can be found [here](http://railsapps.github.io/installing-rails.html)*

### Prepare the system
```
$ sudo apt-get update
$ sudo apt-get upgrade
```

Install git and curl if you don't have them:
```
$ sudo apt-get install git curl
```

### NodeJS
```
$ sudo apt-get install nodejs
```

### Redis
```
$ sudo apt-get install redis-server
```

### RVM and Ruby 2.3.1

```
$ \curl -L https://get.rvm.io | bash -s stable --ruby=2.3.1
```
ATTENTION! After installation is finished, you will be asked to run some command like this:
```
$ source /home/$USER/.rvm/scripts/rvm
```
Please, check for the instructions on the terminal.

Check if Ruby and Gem Manager are installed properly:
```
$ ruby -v
$ gem -v
```

Configure and update gem manager and its gems:
```
$ rvm gemset user global
$ gem update --system
$ gem update
```

### Bundler and Nokogiri
```
$ gem install bundler
$ gem install nokogiri
```

If you have issues with installing Nokogiri, first make sure you have all the tooling necessary to compile C extensions:
```
$ sudo apt-get install build-essential patch
```

It’s also possible that you don’t have important development header files installed on your system for Nokogiri:
```
$ sudo apt-get install ruby-dev zlib1g-dev liblzma-dev
```

Then try to install Nokogiri again.

### Rails 5.0.1
```
$ gem install rails --version=5.0.1
```

Check if rails is installed correctly:
```
$ rails -v
```

At this point everything should be set up to run the application.

## Option #2 (Automated)

#### Work on progress 
