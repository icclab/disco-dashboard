##
# User model relationships, validations, and underlying usertypes and its methods.
class User < ApplicationRecord
  has_many :infrastructures, dependent: :destroy
  has_many :images,   through: :infrastructures
  has_many :flavors,  through: :infrastructures
  has_many :keypairs, through: :infrastructures
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
end
