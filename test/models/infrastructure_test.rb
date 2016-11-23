require 'test_helper'

class InfrastructureTest < ActiveSupport::TestCase
  def setup
    @user = users(:professor)
    @infrastructure = @user.infrastructures.build(name: 'test',
                                                  username: 'test',
                                                  auth_url: 'test.com',
                                                  tenant: 'test' )
  end

  test "should be valid" do
    assert @infrastructure.valid?, @infrastructure.errors.full_messages
  end

  test "name should be present" do
    @infrastructure.name = ""
    assert_not @infrastructure.valid?
  end

  test "username should be present" do
    @infrastructure.username = ""
    assert_not @infrastructure.valid?
  end

  test "auth_url should be present" do
    @infrastructure.auth_url = ""
    assert_not @infrastructure.valid?
  end

  test "tenant should be present" do
    @infrastructure.tenant = ""
    assert_not @infrastructure.valid?
  end
end
