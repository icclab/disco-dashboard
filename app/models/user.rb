class User < ApplicationRecord
  validates :username, presence: true
  validates :password, presence: true
  validates :auth_url, presence: true
  validates :tenant,   presence: true
  validates :disco_ip, presence: true,
                       format: { with: Resolv::IPv4::Regex }
  has_secure_password
end
