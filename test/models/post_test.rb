require "test_helper"

class PostTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "requires a title" do
    assert_not Post.new(title: "").valid?
  end

  test "enqueues PostCreatedJob after create" do
    assert_enqueued_with(job: PostCreatedJob) do
      Post.create!(title: "Hello")
    end
  end
end
