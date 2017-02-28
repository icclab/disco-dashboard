# Setting up the system for DISCO Dashboard 

*Following instructions were tested on OS Ubuntu 14.04. We don't guaranteee that everything will work on a different systems, that's why we recommend you to try to use first option.*

*More detailed Rails installation guide for both Ubuntu and OSX can be found [here](http://railsapps.github.io/installing-rails.html)*

## Option #1 (Manual) *recommended*

### Prepare the system
```
$ sudo apt-get update
$ sudo apt-get upgrade
```

Install git and curl:
```
$ sudo apt-get install git curl
```

Install NodeJS:
```
$ sudo apt-get install nodejs
```

Install Redis:
```
$ sudo apt-get install redis-server
```

Install Ruby Version Manager (RVM) and Ruby 2.3.1
```
$ \curl -L https://get.rvm.io | bash -s stable --ruby=2.3.1
$ source /home/$USER/.rvm/scripts/rvm
```
To be sure that installation is complete, please, check for the instructions on the terminal.

Check if Ruby and Gem Manager are installed properly:
```
$ ruby -v
$ gem -v
```

Configure and update gem manager and its gems:
```
$ gem update --system
$ rvm gemset user global
$ gem update
```

Install Bundler and Nokogiri gems:
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

Install Rails 5.0.1
```
$ gem install rails --version=5.0.1
```

Check if rails is installed correctly:
```
$ rails -v
```

### Initialize the application
Move to the work directory where you want to have the app and clone the repo if you haven't done it before: 
```
$ git clone https://github.com/icclab/disco-dashboard.git
```

Move to app's folder and run bundle install:
```
$ cd disco-dashboard
$ bundle install --without production
```

Execute [figaro](https://github.com/laserlemon/figaro) gem:
```
$ bundle exec figaro install
```

Set up environment variables in *config/application.yml*:
```
development:
  # DISCO endpoint (e.g. 'http://127.0.0.1:8080/haas/')
  disco_ip: 'http://xxx.xxx.xxx.xxx:port/haas/' 
  # App needs a fingerprint of the keypairs generated by DISCO framework to not load those keypairs.
  # The one below was used when this setup guide was written. 
  # In case it is outdated, you need to update it.
  fingerprint: "b2:c1:f1:50:e3:f8:7b:88:fa:e3:b1:97:a5:6b:32:27"
```

Next, do the database migration:
```
$ rails db:migrate
```

Fill the database with data (This file located in './db/seeds.rb' can be edited as you need it):
```
$ rails db:seed
```

To get basic information about app you can run:
```
$ rails about
```

At this point everything should be set up to run the application.

## Option #2 (Automated)

Install git if you don't have it"
```
$ sudo apt-get install git
```

Clone current repository to your working directory:
```
$ git clone https://github.com/icclab/disco-dashboard.git
```

Then run following commands:
```
$ cd disco-dashboard
$ chmod +x setup.sh
$ ./setup.sh
```

Set up environment variables in *config/application.yml*:
```
development:
  # DISCO endpoint (e.g. 'http://127.0.0.1:8080/haas/')
  disco_ip: 'http://xxx.xxx.xxx.xxx:port/haas/' 
  # App needs a fingerprint of the keypairs generated by DISCO framework to not load those keypairs.
  # The one below was used when this setup guide was written. 
  # In case it is outdated, you need to update it.
  fingerprint: "b2:c1:f1:50:e3:f8:7b:88:fa:e3:b1:97:a5:6b:32:27"
```

After everything finishes, check whether you can get brief information about application:
```
$ source /home/$USER/.rvm/scripts/rvm
$ rails about
```