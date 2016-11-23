require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(email: "example@user.com", usertype: 1,
                     password: "password", password_confirmation: "password")
  end

  test "should be valid" do
    assert @user.valid?, @user.errors.full_messages
  end

  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email should have a maximum length" do
    @user.email = ("a" * 255) + "@user.com"
    assert_not @user.valid?
  end

  test "email should have the right format" do
    %w[foo@mail.ch bar@gg.ac.kr foobar@gmail.ru foo_bar@zhaw.co FooBar8@mail.com].each do |email|
      @user.email = email
      assert @user.valid?, @user.email
    end
    %w[foo-bar@user foobar$user.com *bar@mail.co].each do |email|
      @user.email = email
      assert_not @user.valid?, @user.email
    end
  end

  test "password should be present" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
end
