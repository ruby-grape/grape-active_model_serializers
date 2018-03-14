# Releasing Grape::ActiveModelSerializers

There're no particular rules about when to release grape-active_model_serializers. Release bug fixes frequently, features not so frequently and breaking API changes rarely.

### Release

Run tests, check that all tests succeed locally.

```
bundle install
rake
```

Check that the last build succeeded in [Travis CI](https://travis-ci.org/ruby-grape/grape-active_model_serializers) for all supported platforms.

Change "Next Release" in [CHANGELOG.md](CHANGELOG.md) to the new version.

```
### 0.7.2 (February 6, 2014)
```

Remove the line with "Your contribution here.", since there will be no more contributions to this release.

Commit your changes.

```
git add CHANGELOG.md lib/grape-active_model_serializers/version.rb
git commit -m "Preparing for release, 0.7.2."
git push origin master
```

Release.

```
$ rake release

grape-active_model_serializers 0.7.2 built to pkg/grape-active_model_serializers-0.7.2.gem.
Tagged v0.7.2.
Pushed git commits and tags.
Pushed grape-active_model_serializers 0.7.2 to rubygems.org.
```

### Prepare for the Next Version

Modify [lib/grape-active_model_serializers/version.rb](lib/grape-active_model_serializers/version.rb), increment the third number (eg. change `0.7.2` to `0.7.3`).


```ruby
module Grape
  module ActiveModelSerializers
    VERSION = '0.7.3'.freeze
  end
end
```

Add the next release to [CHANGELOG.md](CHANGELOG.md).

```
#### 0.7.3 (Next)

* Your contribution here.
```

Commit your changes.

```
git add CHANGELOG.md lib/grape-active_model_serializers/version.rb
git commit -m "Preparing for next development iteration, 0.7.3."
git push origin master
```
