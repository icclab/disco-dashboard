require 'test_helper'

class ClusterTest < ActiveSupport::TestCase
  def setup
    @infrastructure = infrastructures(:one)
    @cluster = @infrastructure.clusters.build(name: "test",
                                              master_image: "1",
                                              slave_image: "1",
                                              master_flavor: "1",
                                              slave_flavor: "1",
                                              slave_num: 1,
                                              external_ip: 0,
                                              slave_on_master: true)
  end

  test "should be valid" do
    assert @cluster.valid?, @cluster.errors.full_messages
  end

  test "name should be present" do
    @cluster.name = ""
    assert_not @cluster.valid?
  end

  test "master image should be present" do
    @cluster.master_image = ""
    assert_not @cluster.valid?
  end

  test "slave image should be present" do
    @cluster.slave_image = ""
    assert_not @cluster.valid?
  end

  test "master flavor should be present" do
    @cluster.master_flavor = ""
    assert_not @cluster.valid?
  end

  test "slave flavor should be present" do
    @cluster.slave_flavor = ""
    assert_not @cluster.valid?
  end

  test "slave num should be present" do
    @cluster.slave_num = nil
    assert_not @cluster.valid?
  end

  test "slave num should be larger than zero" do
    @cluster.slave_num = 0
    assert_not @cluster.valid?
  end

  test "slave on master should be present" do
    @cluster.slave_on_master = nil
    assert_not @cluster.valid?
  end

end
