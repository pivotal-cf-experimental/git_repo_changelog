Generates a changelog of Pivotal Tracker story titles and URLs for a range of git commits and authors. Git submodules will be traversed.

Story ids must be contained in commit messages in the form `[#123456]`.

Usage:

```
$ git clone <this repo>
$ cd git_repo_changelog
$ bundle
$ export TRACKER_API_TOKEN=<your Pivotal Tracker API token>
$ bundle exec rake changelog[repository_path,start_git_ref,end_git_ref,authors]
```

- `repository_path` - local path to repo you'd like the changelog for
- `start_git_ref`, `end_git_ref` - can be tags, shas, branches, etc
- `authors` - a space delimited list of email addresses or empty string for all authors

**WARNING:** Running this will run git checkouts in the passed in repository_path.

Example:

```
$ bundle
$ export TRACKER_API_TOKEN=12345670
$ bundle exec rake changelog[/temp/workspace/cf-release,v211,v212,'mboedicker@pivotal.io cpiraino@pivotal.io']
cf-release
- cloudfoundry/gorouter #88: Added cache headers to heartbeat response [details](https://www.pivotaltracker.com/story/show/96503820)

src/routing-api
- operator should be able to discover metrics for the routing api service [details](https://www.pivotaltracker.com/story/show/85546998)
- Check performance of 200 services heartbeating their routes [details](https://www.pivotaltracker.com/story/show/91732170)

src/acceptance-tests
- CATS broker should return AsyncRequired error for async plans when request does not include accepts_incomplete [details](https://www.pivotaltracker.com/story/show/95212618)
```
