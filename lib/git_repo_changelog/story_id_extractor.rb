module GitRepoChangelog
  # Extract Pivotal Tracker story ids from git commit messages.
  class StoryIdExtractor
    def story_ids(commit_message)
      commit_message.scan(/\[#(\d+)\]/).flatten
    end
  end
end
