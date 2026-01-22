require "test_helper"

class SubprojectTest < ActiveSupport::TestCase
  test "should be valid with required attributes" do
    subproject = Subproject.new(
      project: projects(:website_redesign),
      name: "Test Subproject"
    )
    assert subproject.valid?
  end

  test "should require name" do
    subproject = Subproject.new(project: projects(:website_redesign))
    assert_not subproject.valid?
    assert_includes subproject.errors[:name], "can't be blank"
  end

  test "should validate status inclusion" do
    subproject = Subproject.new(
      project: projects(:website_redesign),
      name: "Test",
      status: "invalid_status"
    )
    assert_not subproject.valid?
    assert_includes subproject.errors[:status], "is not included in the list"
  end

  test "should default status to offered" do
    subproject = Subproject.new(
      project: projects(:website_redesign),
      name: "Test"
    )
    assert_equal "offered", subproject.status
  end

  test "should calculate total hours" do
    subproject = subprojects(:design)
    assert_respond_to subproject, :total_hours
  end

  test "should calculate budget percentage used" do
    subproject = subprojects(:design)
    assert_respond_to subproject, :budget_percentage_used
  end

  test "active scope returns accepted subprojects" do
    accepted = subprojects(:design)
    offered = subprojects(:testing)
    assert_includes Subproject.active, accepted
    assert_not_includes Subproject.active, offered
  end

  test "status helper methods" do
    subproject = Subproject.new(status: "accepted")
    assert subproject.accepted?
    assert subproject.can_log_time?
    assert_not subproject.offered?
    assert_not subproject.rejected?
    assert_not subproject.finished?
  end
end
