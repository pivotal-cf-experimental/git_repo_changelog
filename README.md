Generate a changelog of Pivotal Tracker story ids for a range of git commits and authors.

Git submodules will be traversed.

Story ids are contained in commit messages in the form `[#123456]`.

Usage:

```
bundle exec rake changelog[repository_path,start_git_ref,end_git_ref,authors]
```

WARNING: Running this will run git checkouts in the passed in repo_path.

Example:

```
bundle
bundle exec rake changelog[/Users/pivotal/workspace/cf-release,v211,v212,'mboedicker@pivotal.io cpiraino@pivotal.io']
cf-release
96503820

src/routing-api
85546998
91732170

src/acceptance-tests
95212618

```
