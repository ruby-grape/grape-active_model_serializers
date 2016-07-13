# Grape::ActiveModelSerializers

Use [active_model_serializers](https://github.com/rails-api/active_model_serializers) with [Grape](https://github.com/intridea/grape)!

[![Build Status](https://api.travis-ci.org/ruby-grape/grape-active_model_serializers.svg)](http://travis-ci.org/ruby-grape/grape-active_model_serializers) [![Dependency Status](https://gemnasium.com/ruby-grape/grape-active_model_serializers.svg)](https://gemnasium.com/ruby-grape/grape-active_model_serializers) [![Code Climate](https://codeclimate.com/github/jrhe/grape-active_model_serializers.svg)](https://codeclimate.com/github/jrhe/grape-active_model_serializers)

## Installation

Add the `grape` and `grape-active_model_serializers` gems to Gemfile and run `bundle install`.

```ruby
gem 'grape-active_model_serializers'
```

See [UPGRADING](UPGRADING.md) if you're upgrading from a previous version.

## Dependencies

* >= Ruby v2.2
* >= [grape](https://github.com/intridea/grape) v0.8.0
* >= [active_model_serializers](https://github.com/rails-api/active_model_serializers) v0.10.0

## Usage

### Require grape-active_model_serializers

```ruby
# config.ru
require 'grape-active_model_serializers'
```

### Tell your API to use Grape::Formatter::ActiveModelSerializers

```ruby
class API < Grape::API
  format :json
  formatter :json, Grape::Formatter::ActiveModelSerializers
end
```

### Writing Serializers

See [active_model_serializers](https://github.com/rails-api/active_model_serializers)


### Serializers are inferred by active_record model names

`grape-active_model_serializers` will search for serializers for the objects returned by your grape API.

```ruby
namespace :users do
  get ":id" do
    @user = User.find(params[:id])
  end
end
```
In this case, as User objects are being returned, grape-active_model_serializers will look for a serializer named UserSerializer.

### Array Roots

When serializing an array, the array root is set to the innermost namespace name if there is one, otherwise it is set to the route name.

In the following API the array root is `users`.

```ruby
namespace :users do
  get ":id" do
    @user = User.find(params[:id])
  end
end
```

In the following example the array root is `people`.

```ruby
get "people" do
  @user = User.all
end
```

### API Versioning

If your Grape API is versioned you must namespace your serializers accordingly.

For example, given the following API.

```ruby
module CandyBar
  class Core < Grape::API
    version 'candy_bar', using: :header, vendor: 'acme'
  end
end

module Chocolate
  class Core < Grape::API
    version 'chocolate', using: :header, vendor: 'acme'
  end
end

class API < Grape::API
  format :json
  formatter :json, Grape::Formatter::ActiveModelSerializers

  mount CandyBar::Core
  mount Chocolate::Core
end
```

Namespace your serializers according to each version.

```ruby
module CandyBar
  class UserSerializer < ActiveModel::Serializer
    attributes :first_name, :last_name, :email
  end
end

module Chocolate
  class UserSerializer < ActiveModel::Serializer
    attributes :first_name, :last_name
  end
end
```

This keeps serializers organized.

```
app
└── api
    ├── chocolate
        └── core.rb
    └── candy_bar
        └── core.rb
    api.rb
└── serializers
    ├── chocolate
        └── user_serializer.rb
    └── candy_bar
        └── user_serializer.rb
```

Or as follows.

```
└── serializers
    ├── chocolate_user_serializer.rb
    └── candy_bar_user_serializer.rb
```

ActiveModelSerializer will fetch automatically the right serializer to render.

### Manually specifying serializer options

```ruby
# Serializer options can be specified on routes or namespaces.
namespace 'foo', serializer: BarSerializer do
  get "/" do
    # will use "bar" serializer
  end

  # Options specified on a route or namespace override those of the containing namespace.
  get "/home", serializer: HomeSerializer do
    # will use "home" serializer
  end

  # All standard options for `ActiveModel::Serializers` are supported.
  get "/fancy_homes", root: 'world', each_serializer: FancyHomesSerializer
  ...
  end
end
```

### Custom Metadata

```ruby
# Control any additional metadata using meta and meta_key
get "/homes"
  collection = Home.all
  render collection, { meta: { page: 5, current_page: 3 }, meta_key: :pagination_info }
end
```

### Default Serializer Options

```ruby
helpers do
  def default_serializer_options
    { only: params[:only], except: params[:except] }
  end
end
```

### Current User

One of the nice features of ActiveModel::Serializers is that it provides access to the authorization context via the `current_user`.

In Grape, you can get the same behavior by defining a `current_user` helper method.

```ruby
helpers do
  def current_user
    @current_user ||= User.where(access_token: params[:token]).first
  end

  def authenticate!
    error!('401 Unauthenticated', 401) unless current_user
  end
end
```

Then, in your serializer, you could show or hide some elements based on the current user's permissions.

```ruby
class PostSerializer < ActiveModel::Serializer
  def include_admin_comments?
    current_user.roles.member? :admin
  end
end
```

*Note*: in the [0.9.x stable version of active model serializers](https://github.com/rails-api/active_model_serializers/tree/0-9-stable#customizing-scope), you have to access current user on scope -  so `scope.current_user`.

### Full Example

```ruby
class User < ActiveRecord::Base
  attr_accessor :first_name, :last_name, :password, :email
end

class UserSerializer < ActiveModel::Serializer
  attributes :first_name, :last_name
end

class API < Grape::API
  get("/home") do
    User.new({first_name: 'JR', last_name: 'HE', email: 'contact@jrhe.co.uk'})
  end
end

API.new.get "/home" # => '{ user: { first_name: "JR", last_name: "HE" } }'
```

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## History

Structured and based upon [grape-rabl](https://github.com/LTe/grape-rabl).
