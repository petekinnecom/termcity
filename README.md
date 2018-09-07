# Termcity!

See TeamCity build status for a branch in your terminal. Pipe it to grep or whatever. Get nicely formatted links if you use iTerm2.

## Client installation

```
gem install termcity
```

Then you can run the `termcity` command. Here is the help text:

```
Run termcity to see your test results on TeamCity:

termcity --branch myBranchName --project MyProjectId

[Options]

-b, --branch: defaults to current repo branch
-p, --project: defaults to camelcasing repo directory

[CREDENTIALS]:

The backend uses your Github organization memberships to verify your
access to the data. You must configure the CLI with a token granting
it access to read your org memberships:

1. Visit https://github.com/settings/tokens/new
2. Generate a new token
3. Only grant the `read:org` permission (leave all others unchecked)
4. Paste the token in the configuration file as specified below.

[CONFIGURATION]
Put a json formatted file at ~/.termcity with the following data:

  {
    "host":  "https://my.termcity.api.com",
    "token": "your github auth token"
  }

[OUTPUT]

Builds are listed in alphabetical order. Builds that have a result for
the latest revision but are also re-enqueued have a ",q" next to them.
For example, "failed,q" means the latest build on the branch has
failed, but it is enqueued to run again.
```

Why does the backend use a github token to check your org? TeamCity only has username/password authentication. And you don't want to give away your TeamCity password, I think.

## Why is there a custom server? Doesn't TeamCity have an API?

TeamCity has an API, but it's not easy to search for things. When searching for builds on a branch, you must specify how many builds from the history to search through. If you set the `lookupLimit` too low, you might only find half the builds. If you set it too high, the query will be really slow. If you set it juuuuust right, the query will still be slow because TeamCity's API is slow.  Like ~ 10-20 seconds per search query slow. Ouch.

The backend just syncs the recent builds with TeamCity each minute. This query is fast because there's almost no filters applied and restricts the search by time. The gem then queries this custom backend and it is faster because of science.

## Server Installation

You can tell it's a Phoenix app [because of the way it is](https://youtu.be/Hm3JodBR-vs?t=66). It can be configured using various environment variables as specified in the `config.exs` and `prod.exs`.


