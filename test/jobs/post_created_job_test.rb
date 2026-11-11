require "test_helper"

class PostCreatedJobTest < ActiveJob::TestCase
  test "runs for a post" do
    assert_nothing_raised { PostCreatedJob.perform_now(posts(:one)) }
  end
end
