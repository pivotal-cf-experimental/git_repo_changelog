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

      root_shas = commits(start_ref, end_ref, authors)
      story_id_extractor = GitRepoChangelog::StoryIdExtractor.new
      root_shas.each do |root_sha|
        message = commit_message(root_sha)
        story_ids = story_id_extractor.story_ids(message)
        story_map.add(@name, story_ids)

        story_map.merge(submodule_commit_stories(root_sha))
      end

      story_map
    end

    def commits(start_ref, end_ref, authors)
      author_args = authors.map { |author| "--author=#{author}" }.join(' ')

      Dir.chdir(@root_path) do
        `git log --format=%H #{start_ref}..#{end_ref} #{author_args}`.split
      end
    end

    def commit_submodules_changed(sha)
      Dir.chdir(@root_path) do
        output = `git show #{sha}`
        output.scan(%r{
        \+\+\+\ b\/([^\n]+)\n
@@\ -1\ \+1\ @@\n
-Subproject\ commit\ [a-f0-9]{40}\n
\+Subproject\ commit\ [a-f0-9]{40}
}mx).flatten
      end
    end

    def submodule_commit_message(root_sha, path)
      Dir.chdir(@root_path) do
        `git checkout #{root_sha}`
        `git submodule update --init --recursive`
        Dir.chdir(path) do
          `git log --format=%B -n 1`
        end
      end
    end

    def commit_message(sha)
      Dir.chdir(@root_path) do
        `git log #{sha} --format=%B -n 1`
      end
    end

    private

    def submodule_commit_stories(root_sha)
      story_map = GitRepoChangelog::StoryMap.new
      story_id_extractor = GitRepoChangelog::StoryIdExtractor.new

      submodule_commits = commit_submodules_changed(root_sha)
      submodule_commits.each do |submodule_path|
        message = submodule_commit_message(root_sha, submodule_path)
        story_ids = story_id_extractor.story_ids(message)
        story_map.add(submodule_path, story_ids)
      end

      story_map
    end
  end
end
