require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "should validate status inclusion" do
    project = Project.new(
      client: clients(:one),
      name: "Test",
      status: "invalid_status"
    )
    assert_not project.valid?
    assert_includes project.errors[:status], "is not included in the list"
  end

  test "should default status to offered" do
    project = Project.new(
      client: clients(:one),
      name: "Test"
    )
    assert_equal "offered", project.status
  end

  test "active scope returns accepted projects" do
    accepted = projects(:website_redesign)
    rejected = projects(:one)
    assert_includes Project.active, accepted
    assert_not_includes Project.active, rejected
  end

  test "status helper methods" do
    project = Project.new(status: "accepted")
    assert project.accepted?
    assert project.can_log_time?
    assert_not project.offered?
    assert_not project.rejected?
    assert_not project.finished?
  end
end
