require 'tracker_api'
module GitRepoChangelog
  # Formatter that looks up story titles in Pivotal Tracker.
  class TrackerFormatter
    def initialize(tracker_client)
      @tracker_client = tracker_client
    end

    def format(story_map)
      output = ''

      story_map.to_hash.each do |repo, story_ids|
        output << "#{repo}\n"
        story_ids.each do |story_id|
          populate(output, story_id)
        end
        output << "\n"
      end

      output
    end

    def populate(output, story_id)
      story = @tracker_client.story(story_id)
      output << "- #{story.name} [details](#{story.url})\n"
    rescue => e
      failure = 'failed to fetch story title'
      output << "- #{story_id} #{failure} (error: #{e.message})\n"
    end
  end
end
