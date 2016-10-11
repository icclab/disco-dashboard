class User < ApplicationRecord
  attr_accessor :remember_token

  has_many :clusters, dependent: :destroy

  before_save { self.username.downcase! }

  validates :username, presence: true
  validates :password, presence: true
  validates :auth_url, presence: true
  validates :tenant,   presence: true
  has_secure_password

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

  # Remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Return true if the given token matches the digest.
  def authenticated?(remember_token)
    if remember_digest.nil?
      false
    else
      BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
  end

  # Forgets a user
  def forget
    update_attribute(:remember_digest, nil)
  end
end
