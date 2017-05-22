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

##
# User model relationships, validations, and underlying usertypes and its methods.
class User < ApplicationRecord
  has_many :infrastructures, dependent: :destroy
  has_many :images,   through: :infrastructures
  has_many :flavors,  through: :infrastructures
  has_many :clusters, through: :infrastructures
  has_many :assignments
  has_many :groups, through: :assignments

  # Ensures that all emails are saved in downcase
  before_save { self.email.downcase! }
  # Regex for email validity checking
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  ##
  # User class instance methods.
  class << self
    # Returns the hash digest of the given string.
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # Returns a random token.
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  ##
  # Usertype module contains modules for different user roles to define their permission policy.
  #   - sidebar? => returns true if user can see a sidebar on a dashboard
  #   - infrastructure_permissions? => returns true if user can add/use/delete infrastructures
  #   - cluster_permissions? => returns true if user can create/delete clusters
  #   - group_permissions? => returns true if user can create/delete groups and assign_new_user/associate_cluster to the groups
  #   - task_permissions? => returns true if user can create/delete tasks
  #
  # This module can be extended with new usertypes and underlying methods.
  module Usertype
    module Admin
      class << self
        def sidebar?
          true
        end

        def infrastructure_permissions?
          true
        end

        def cluster_permissions?
          true
        end

        def group_permissions?
          true
        end

        def task_permissions?
          true
        end

        def is_admin?
          true
        end
      end
    end

    module Professor
      class << self
        def sidebar?
          true
        end

        def infrastructure_permissions?
          true
        end

        def cluster_permissions?
          true
        end

        def group_permissions?
          true
        end

        def task_permissions?
          true
        end

        def is_admin?
          false
        end
      end
    end

    module Student
      class << self
        def sidebar?
          false
        end

        def infrastructure_permissions?
          false
        end

        def cluster_permissions?
          false
        end

        def group_permissions?
          false
        end

        def task_permissions?
          false
        end
      end

      def is_admin?
        false
      end
    end
  end

  def sidebar?
    self.usertype.sidebar?
  end

  def infrastructure_permissions?
    self.usertype.infrastructure_permissions?
  end

  def cluster_permissions?
    self.usertype.cluster_permissions?
  end

  def group_permissions?
    self.usertype.group_permissions?
  end

  def task_permissions?
    self.usertype.task_permissions?
  end

  # Returns the module corresponding to the user role
  def usertype
    User::Usertype.const_get(self.role.capitalize)
  end

  def is_admin?
    self.usertype.is_admin?
  end
end
