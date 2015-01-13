# Grape::ActiveModelSerializers

Use [active_model_serializers](https://github.com/rails-api/active_model_serializers) with [Grape](https://github.com/intridea/grape)!

[![Build Status](https://api.travis-ci.org/jrhe/grape-active_model_serializers.png)](http://travis-ci.org/jrhe/grape-active_model_serializers) [![Dependency Status](https://gemnasium.com/jrhe/grape-active_model_serializers.png)](https://gemnasium.com/jrhe/grape-active_model_serializers) [![Code Climate](https://codeclimate.com/github/jrhe/grape-active_model_serializers.png)](https://codeclimate.com/github/jrhe/grape-active_model_serializers)

## Breaking Changes
#### v1.0.0
* *BREAKING* Changes behaviour of root keys when serialising arrays. See [Array roots](https://github.com/jrhe/grape-active_model_serializers#array-roots)

## Installation

Add the `grape` and `grape-active_model_serializers` gems to Gemfile.

```ruby
gem 'grape'
gem 'grape-active_model_serializers'
```

And then execute:

    bundle

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


### Writing serializers

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

### Array roots
When serializing an array, the array root is set to the innermost namespace name if there is one, otherwise it is set to the route name (e.g. get 'name').

```ruby
namespace :users do
  get ":id" do
    @user = User.find(params[:id])
  end
end
# root = users
```

```ruby
get "people" do
  @user = User.all
end
# root = people
```

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

### Custom metadata along with the resources

```ruby
# Control any additional metadata using meta and meta_key
get "/homes"
  collection = Home.all
  render collection, { meta: { page: 5, current_page: 3 }, meta_key: :pagination_info }
end
```

### Support for `default_serializer_options`

```ruby
helpers do
  def default_serializer_options
    {only: params[:only], except: params[:except]}
  end
end
```

### current_user

One of the nice features of ActiveModel::Serializers is that it
provides access to the authorization context via the `current_user`.

In Grape, you can get the same behavior by defining a `current_user`
helper method:

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

Then, in your serializer, you could show or hide some elements
based on the current user's permissions:

```ruby
class PostSerializer < ActiveModel::Serializer
...
  def include_admin_comments?
    current_user.roles.member? :admin
  end
end
```

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


## RSpec

See "Writing Tests" in https://github.com/intridea/grape.

Enjoy :)

## Changelog

#### Next
* Adds support for Grape 0.10.x


#### v1.2.1
* Adds support for active model serializer 0.9.x


#### v1.0.0
* Released on rubygems.org
* *BREAKING* Changes behaviour of root keys when serialising arrays. See [Array roots](https://github.com/jrhe/grape-active_model_serializers#array-roots)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Thanks to
The developers and maintainers of:
[active_model_serializers](https://github.com/rails-api/active_model_serializers)
[Grape](https://github.com/intridea/grape)!

Structured and based upon [grape-rabl](https://github.com/LTe/grape-rabl).
