require 'git_repo_changelog/story_id_extractor'
require 'git_repo_changelog/story_map'

module GitRepoChangelog
  # Git repository to extract Pivotal Tracker stories from.
  class GitRepo
    def initialize(root_path)
      @root_path = root_path
      @name = File.basename(root_path)
    end

    def release_stories(start_ref, end_ref, authors)
      story_map = GitRepoChangelog::StoryMap.new

      root_shas = commits(@root_path, start_ref, end_ref, authors)
      story_id_extractor = GitRepoChangelog::StoryIdExtractor.new
      root_shas.each do |root_sha|
        message = commit_message(@root_path, root_sha)
        story_ids = story_id_extractor.story_ids(message)
        story_map.add(@name, story_ids)
      end

      # get the stories of the submodules.
      story_map.merge(submodule_commit_stories(start_ref, end_ref, authors))

      story_map
    end

    def commits(path, start_ref, end_ref, authors)
      author_args = authors.map { |author| "--author=#{author}" }.join(' ')

      Dir.chdir(path) do
        `git log --format=%H #{start_ref}..#{end_ref} #{author_args}`.split
      end
    end

    def commit_message(path, sha)
      Dir.chdir(path) do
        `git log #{sha} --format=%B -n 1`
      end
    end

    def submodule_commit_sha(root_tag, submodule_shas)
      `git checkout #{root_tag}`
      `git submodule update --init`

      submodule_status = `git submodule status`
      submodule_status.each_line do |line|
        sub_pair = line.split

        submodule = sub_pair[1]
        sha = sub_pair[0]

        if submodule_shas.has_key?(submodule)
          submodule_shas[submodule] << sha
        else
          submodule_shas[submodule] = [sha]
        end
      end
    end

    private

    def submodule_commit_stories(start_ref, end_ref, authors)
      story_map = GitRepoChangelog::StoryMap.new
      story_id_extractor = GitRepoChangelog::StoryIdExtractor.new

      submodule_shas = {}

      Dir.chdir(@root_path) do
        [start_ref, end_ref].each do |ref|
          submodule_commit_sha(ref, submodule_shas)
        end
      end

      submodule_shas.each_key do |submodule_name|
        puts submodule_name

        Dir.chdir(@root_path) do
            sub_commits = commits(submodule_name, submodule_shas[submodule_name][0], submodule_shas[submodule_name][1], authors)
            sub_commits.each do |sub_sha|
              message = commit_message(submodule_name, sub_sha)
              story_ids = story_id_extractor.story_ids(message)
              story_map.add(submodule_name, story_ids)

              puts "The pair:" + submodule_name + story_ids.to_s
            end
        end
      end

      story_map
    end
  end
end
