class PostCreatedJob < ApplicationJob
  queue_as :default

  def perform(post)
    Rails.logger.info "PostCreatedJob: post ##{post.id} (#{post.title.inspect}) was created"
  end
end
