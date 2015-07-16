require 'git_repo_changelog/formatter'
require 'git_repo_changelog/story_map'

describe GitRepoChangelog::Formatter do
  describe '#format' do
    it 'formats a hash of story ids' do
      story_map = GitRepoChangelog::StoryMap.new
      story_map.add('src/routing-api', ['85546998'])
      story_map.add('src/acceptance-tests', ['95212618'])

      formatter = GitRepoChangelog::Formatter.new
      formatted = formatter.format(story_map)
      expect(formatted).to eq <<-EOS
src/routing-api
85546998

src/acceptance-tests
95212618

      EOS
    end
  end
end
