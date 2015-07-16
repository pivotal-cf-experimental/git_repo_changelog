module GitRepoChangelog
  # Format a story map for output.
  class Formatter
    def format(story_map)
      output = ''

      story_map.to_hash.each do |repo, story_ids|
        output << "#{repo}\n"
        output << story_ids.join("\n")
        output << "\n\n"
      end

      output
    end
  end
end
