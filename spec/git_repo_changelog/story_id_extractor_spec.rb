require 'git_repo_changelog/story_id_extractor'

describe GitRepoChangelog::StoryIdExtractor do
  describe '#story_id' do
    it 'extracts the story id' do
      story_id_extractor = GitRepoChangelog::StoryIdExtractor.new
      expect(story_id_extractor.story_ids(
               "Short message\n\nLong Message\n\n[#12345] [#67890]")).to eq(
                 %w(12345 67890))
    end
  end
end
