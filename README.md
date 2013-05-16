# Grape::ActiveModelSerializers

Use [active_model_serializers](https://github.com/rails-api/active_model_serializers) with [Grape](https://github.com/intridea/grape)!

[![Build Status](https://api.travis-ci.org/jrhe/grape-active_model_serializers.png)](http://travis-ci.org/jrhe/grape-active_model_serializers) [![Dependency Status](https://gemnasium.com/jrhe/grape-active_model_serializers.png)](https://gemnasium.com/jrhe/grape-active_model_serializers)


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
require 'grape/active_model_serializers'
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

grape-active_model_serializers will search for serializers for the objects returned by your grape API.

```ruby
namespace :users do
  get ":id" do
    @user = User.find(params[:id])
  end
end
```
In this case, as User objects are being returned, grape-active_model_serializers will look for a serializer named UserSerializer.

### Disabling serializer inferrence

You can turn off serializer inferrence.
```ruby
Grape::Formatter::ActiveModelSerializers.infer_serializers = false
```


### Manually specifying serializer options

Serializers can be specified at a route level by with the serializer option. A serializer can be specified by passing the the serializer class or the serializer name. The following are equivalent:

```ruby
get "/home", :serializer => HomeSerializer
...
```
```ruby
get "/home", :serializer => "home"
...
```
```ruby
get "/home", :serializer => :home
...
```

You can also set a serializer at the namespace level. This serializer can/will be overriden if a serilizer is also specified on the route.

```ruby
namespace 'foo', :serializer => :bar do
  get "/" do
    # will use "bar" serializer
  end

  get "/home", :serializer => :home do
    # will use "home" serializer
  end
end
```

Other standard options for `ActiveModel::Serializers` can be provided at either the namespace or route level with the same overriding behavior.

```ruby
get "/home", :root => 'world', :each_serializer => :fancy_home
...
```


### Example

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

API.new.get "/home" # => '{:user=>{:first_name=>"JR", :last_name=>"HE"}}'
```


## Rspec

See "Writing Tests" in https://github.com/intridea/grape.

Enjoy :)

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

Structured and based upon [Grape](https://github.com/LTe/grape-rabl).
