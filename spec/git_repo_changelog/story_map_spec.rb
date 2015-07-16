require 'git_repo_changelog/story_map'

describe GitRepoChangelog::StoryMap do
  describe '#add' do
    context 'when the repo is not in the map' do
      it 'adds a new key' do
        story_map = GitRepoChangelog::StoryMap.new
        story_map.add('repo1', %w(123))
        expect(story_map.to_hash).to eq('repo1' => %w(123))
      end
    end

    context 'when the repo is already in the map' do
      it 'adds the stories to the existing key' do
        story_map = GitRepoChangelog::StoryMap.new
        story_map.add('repo1', %w(123))
        story_map.add('repo1', %w(456 789))
        expect(story_map.to_hash).to eq('repo1' => %w(123 456 789))
      end
    end

    context 'when no story ids are passed in' do
      it 'does not add the repo to the map' do
        story_map = GitRepoChangelog::StoryMap.new
        story_map.add('repo1', [])
        expect(story_map.to_hash).to eq({})
      end
    end
  end

  describe '#merge' do
    it 'merges another story map' do
      story_map1 = GitRepoChangelog::StoryMap.new
      story_map1.add('repo1', %w(123))

      story_map2 = GitRepoChangelog::StoryMap.new
      story_map2.add('repo1', %w(456))
      story_map2.add('repo2', %w(789))

      story_map1.merge(story_map2)
      expect(story_map1.to_hash).to eq(
        'repo1' => %w(123 456), 'repo2' => %w(789))
    end
  end
end
