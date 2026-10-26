# Contributing to Grape::ActiveModelSerializers

This project is work of [many contributors](https://github.com/ruby-grape/grape-active_model_serializers/graphs/contributors).
You're encouraged to submit [pull requests](https://github.com/ruby-grape/grape-active_model_serializers/pulls),
[propose features and discuss issues](https://github.com/ruby-grape/grape-active_model_serializers/issues).
When in doubt, ask a question in the [Grape Google Group](http://groups.google.com/group/ruby-grape).

In the examples below, substitute your Github username for `contributor` in URLs.

## Fork the Project

Fork the [project on Github](https://github.com/ruby-grape/grape-active_model_serializers) and check out your copy.

```
git clone https://github.com/contributor/grape-active_model_serializers.git
cd grape-active_model_serializers
git remote add upstream https://github.com/ruby-grape/grape-active_model_serializers.git
```

## Create a Topic Branch

Make sure your fork is up-to-date and create a topic branch for your feature or bug fix.

```
git checkout master
git pull upstream master
git checkout -b my-feature-branch
```

## Bundle Install and Test

Ensure that you can build the project and run tests.

```
bundle install
bundle exec rake
```

CI retains Grape 2.3 and 3.0 coverage on Ruby 3.2, 3.3, 3.4, and 4.0, adds the documented Ruby 3.1 minimum with Grape 2.3, and tests Grape 2.4, the latest 3.x, and 4.x on Ruby 3.3. Grape 4.x also runs on Ruby 3.4, Ruby 4.0, and ruby-head (allowed to fail). Ruby 3.1 uses Ubuntu 22.04; newer Rubies use the latest Ubuntu runner. Lint runs separately.

Use `GRAPE_VERSION` to select a Grape requirement, resolving the bundle again when switching:

```sh
GRAPE_VERSION='~> 4.0' bundle update
GRAPE_VERSION='~> 4.0' bundle exec rake
```

Use `~> 2.3.0`, `~> 2.4.0`, `~> 3.0.0`, or `~> 3.0` for the other tested versions. Without an override, Bundler selects the latest Grape compatible with your Ruby. `GRAPE_VERSION=HEAD` selects Grape's upstream default branch.

Danger runs without a personal access token or repository secrets. The read-only pull-request workflow generates a report artifact; a separate `workflow_run` workflow posts the report using GitHub's automatically provided `GITHUB_TOKEN`, without checking out or executing pull-request code with write permissions.

## Write Tests

Try to write a test that reproduces the problem you're trying to fix or describes a feature that you want to build.
Add to [spec](spec).

We definitely appreciate pull requests that highlight or reproduce a problem, even without a fix.

## Write Code

Implement your feature or bug fix.

Ruby style is enforced with [RuboCop](https://github.com/bbatsov/rubocop).
Run `bundle exec rubocop` and fix any style issues highlighted.

Make sure that `bundle exec rake` completes without errors.

## Write Documentation

Document any external behavior in the [README](README.md).

## Update Changelog

Add a line to [CHANGELOG](CHANGELOG.md) under *Next Release*.
Make it look like every other line, including your name and link to your Github account.

## Commit Changes

Make sure git knows your name and email address:

```
git config --global user.name "Your Name"
git config --global user.email "contributor@example.com"
```

Writing good commit logs is important. A commit log should describe what changed and why.

```
git add ...
git commit
```

## Push

```
git push origin my-feature-branch
```

## Make a Pull Request

Go to https://github.com/contributor/grape-active_model_serializers and select your feature branch.
Click the 'Pull Request' button and fill out the form. Pull requests are usually reviewed within a few days.

## Rebase

If you've been working on a change for a while, rebase with upstream/master.

```
git fetch upstream
git rebase upstream/master
git push origin my-feature-branch -f
```

## Update CHANGELOG Again

Update the [CHANGELOG](CHANGELOG.md) with the pull request number. A typical entry looks as follows.

```
* [#123](https://github.com/ruby-grape/grape-active_model_serializers/pull/123): Reticulated splines - [@contributor](https://github.com/contributor).
```

Amend your previous commit and force push the changes.

```
git commit --amend
git push origin my-feature-branch -f
```

## Check on Your Pull Request

Go back to your pull request after a few minutes and check its GitHub Actions results. Everything should look green, otherwise fix issues and amend your commit as described above.

## Be Patient

It's likely that your change will not be merged and that the nitpicky maintainers will ask you to do more, or fix seemingly benign problems. Hang on there!

## Thank You

Please do know that we really appreciate and value your time and work. We love you, really.
