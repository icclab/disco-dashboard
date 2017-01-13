#!/bin/bash

#
# Copyright (c) 2015. Zuercher Hochschule fuer Angewandte Wissenschaften
#  All Rights Reserved.
#
#     Licensed under the Apache License, Version 2.0 (the "License"); you may
#     not use this file except in compliance with the License. You may obtain
#     a copy of the License at
#
#          http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#     WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#     License for the specific language governing permissions and limitations
#     under the License.
#

#
#     Author: Saken Kenzhegulov,
#     URL: https://github.com/skenzhegulov
#


# System updates
sudo apt-get update
sudo apt-get upgrade -y
# Curl
sudo apt-get install -y curl
# NodeJS
sudo apt-get install -y nodejs
# Redis
sudo apt-get install -y redis-server

# Downloading and installing RVM and Ruby 2.3.1
\curl -L https://get.rvm.io | bash -s stable --ruby=2.3.1
source /home/$USER/.rvm/scripts/rvm
# Configuring and updating Gem Manager
gem update --system
rvm gemset use global

gem update
# Installing required gems: Bundler and Nokogiri
gem install bundler
gem install nokogiri
# Installing Rails 5.0.1
gem install rails --version=5.0.1

# Checking if everything was properly installed
echo "Checking if all dependencies were properly installed"
nodejs -v
redis-server -v
ruby -v
bundle -v
nokogiri -v
echo "Gem Manager"
gem -v
rails -v
