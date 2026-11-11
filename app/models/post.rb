class Post < ApplicationRecord
  validates :title, presence: true

  # Example background job: runs on Solid Queue after each new post is saved.
  after_create_commit -> { PostCreatedJob.perform_later(self) }
end
