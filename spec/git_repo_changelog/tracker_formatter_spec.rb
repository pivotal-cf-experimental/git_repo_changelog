require 'git_repo_changelog/tracker_formatter'
require 'git_repo_changelog/story_map'

describe GitRepoChangelog::TrackerFormatter do
  describe '#format' do
    it 'formats a hash of story ids' do
      story_map = GitRepoChangelog::StoryMap.new
      story_map.add('src/routing-api', ['85546998'])
      story_map.add('src/acceptance-tests', ['95212618'])

      tracker_client = instance_double(TrackerApi::Client)
      story1 = instance_double(
        TrackerApi::Resources::Story, name: 'story 1 name', url: 'story 1 url')
      story2 = instance_double(
        TrackerApi::Resources::Story, name: 'story 2 name', url: 'story 2 url')
      allow(tracker_client).to receive(:story).with('85546998').and_return(
        story1)
      allow(tracker_client).to receive(:story).with('95212618').and_return(
        story2)

      formatter = GitRepoChangelog::TrackerFormatter.new(tracker_client)
      formatted = formatter.format(story_map)
      expect(formatted).to eq <<-EOS
src/routing-api
- story 1 name [details](story 1 url)

src/acceptance-tests
- story 2 name [details](story 2 url)

      EOS
    end
  end
end
