$LOAD_PATH.unshift(File.expand_path('../..', __FILE__))

require 'git_repo_changelog/git_repo'
require 'git_repo_changelog/formatter'

desc 'Generate a changelog of Pivotal Tracker story ids from git commits'
task :changelog, [:repo_path, :start_ref, :end_ref, :authors] do |_, args|
  git_repo = GitRepoChangelog::GitRepo.new(args.repo_path)
  formatter = GitRepoChangelog::Formatter.new

  story_map = git_repo.release_stories(
    args.start_ref, args.end_ref, args.authors.split)
  puts formatter.format(story_map)
end
