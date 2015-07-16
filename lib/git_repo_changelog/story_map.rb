module GitRepoChangelog
  # Mapping of git repository to Pivotal Tracker story ids.
  class StoryMap
    def initialize
      @data = {}
    end

    def add(repo, story_ids)
      return if story_ids.empty?

      @data[repo] = [] unless @data[repo]
      @data[repo].concat(story_ids)
    end

    def to_hash
      @data
    end

    def merge(other)
      @data.merge!(other.to_hash) do |_, oldval, newval|
        oldval.concat(newval)
      end
    end
  end
end
