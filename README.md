# Table of Contents

- [Grape::ActiveModelSerializers](#grapeactivemodelserializers)
  - [Installation](#installation)
  - [Dependencies](#dependencies)
  - [Usage](#usage)
    - [Require grape-active_model_serializers](#require-grape-active_model_serializers)
    - [Tell your API to use Grape::Formatter::ActiveModelSerializers](#tell-your-api-to-use-grapeformatteractivemodelserializers)
    - [Writing Serializers](#writing-serializers)
    - [Serializers are inferred by active_record model names](#serializers-are-inferred-by-active_record-model-names)
    - [Array Roots](#array-roots)
    - [API Versioning](#api-versioning)
    - [Manually specifying serializer / adapter options](#manually-specifying-serializer--adapter-options)
    - [Error Serialization](#error-serialization)
    - [Custom Metadata](#custom-metadata)
    - [Default Serializer Options](#default-serializer-options)
    - [Current User](#current-user)
    - [Full Example](#full-example)
    - [Swagger Documentation](#swagger-documentation)
  - [Contributing](#contributing)
  - [History](#history)

# Grape::ActiveModelSerializers

Use [active_model_serializers](https://github.com/rails-api/active_model_serializers) with [Grape](https://github.com/intridea/grape)!

[![Gem Version](https://img.shields.io/gem/v/grape-active_model_serializers.svg)](https://rubygems.org/gems/grape-active_model_serializers)
[![Coverage Status](https://coveralls.io/repos/github/ruby-grape/grape-active_model_serializers/badge.svg?branch=master)](https://coveralls.io/github/ruby-grape/grape-active_model_serializers?branch=master)
[![Build Status](https://github.com/ruby-grape/grape-active_model_serializers/actions/workflows/test.yml/badge.svg?branch=master&event=push)](https://github.com/ruby-grape/grape-active_model_serializers/actions/workflows/test.yml?query=branch%3Amaster)

## Installation

Add the `grape` and `grape-active_model_serializers` gems to Gemfile and run `bundle install`.

```ruby
gem 'grape-active_model_serializers'
```

See [UPGRADING](UPGRADING.md) if you're upgrading from a previous version.

## Dependencies

* &gt;= Ruby v3.1
* &gt;= [grape](https://github.com/ruby-grape/grape) v2.3.0
* &gt;= [active_model_serializers](https://github.com/rails-api/active_model_serializers) v0.10.0

CI covers Grape 2.3, 2.4, 3.0, the latest 3.x, and 4.x on compatible Ruby versions through Ruby 4.0. Grape 4.x is tested on Ruby 3.3 and newer. See [CONTRIBUTING](CONTRIBUTING.md#bundle-install-and-test) for local matrix commands.

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

  error_formatter :json, Grape::ErrorFormatter::ActiveModelSerializers
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

### Manually specifying serializer / adapter options

```ruby
# Serializer and adapter options can be specified on routes or namespaces.
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

```ruby
# Serializer and adapter options can also be specified in the body of the route
resource :users do
  get '/:id' do
    if conditional
      # uses UserSerializer and configured default adapter automatically
      current_user
    else
      # uses specified serializer and adapter
      render current_user, serializer: ErrorSerializer, adapter: :attributes
    end
  end
end
```

```ruby
# Adhoc serializer options can be specified in the body of the route
resource :users do
  get '/:id' do
    render current_user, extra: { adhoc_name_option: 'value' }
  end
end

class UserSerializer
  def name
    instance_options[:adhoc_name_option] # accessible in instance_options
  end
end
```

### Error Serialization

Use `Grape::ErrorFormatter::ActiveModelSerializers` for errors, not `Grape::Formatter::ActiveModelSerializers`, which formats successful responses. The error formatter serializes an invalid model with `ActiveModel::Serializer::ErrorSerializer`.

Pass the model itself to `error!`, not `model.errors`. A failed ActiveRecord `update` returns `false`; it does not invoke the error formatter automatically.

```ruby
ActiveModelSerializers.config.adapter = :json_api

class API < Grape::API
  format :json
  formatter :json, Grape::Formatter::ActiveModelSerializers
  error_formatter :json, Grape::ErrorFormatter::ActiveModelSerializers

  params do
    requires :id, type: String
    optional :first_name, type: String
  end
  patch '/users/:id' do
    user = User.find(params[:id])
    attributes = declared(params, include_missing: false).except(:id)
    error!(user, 422) unless user.update(attributes)
    user
  end
end
```

With the `:json_api` adapter, validation failures return HTTP 422 with a [JSON:API errors array](https://jsonapi.org/format/#error-objects). The response shape follows the configured ActiveModelSerializers adapter, not the Grape format name: the example still uses `format :json`. Setting the global adapter also affects successful responses.

### Custom Metadata

```ruby
# Control any additional metadata using meta and meta_key
get "/homes"
  collection = Home.all
  render collection, { meta: { page: 5, current_page: 3 }, meta_key: :pagination_info }
end
```

### Default Serializer Options

Define `default_serializer_options` as a Grape helper to supply options for each request. AMS 0.10 uses `fields` for attribute filtering, not the legacy `only`/`except` options; `exclude` is not a supported filtering option either.

```ruby
helpers do
  def default_serializer_options
    { fields: params[:fields] }
  end
end

params do
  optional :fields, type: [String]
end
get '/users' do
  User.all
end
```

For the `:attributes` and `:json` adapters, a request such as `/users?fields[]=first_name` selects only `first_name` from the serializer's attributes. Omitting `fields` leaves the attributes unchanged. Namespace and route options override defaults with the same key.

The `:json_api` adapter instead expects a hash keyed by resource type, for example `{ fields: { users: [:first_name, :last_name] } }`. See the [AMS JSON:API adapter documentation](https://github.com/rails-api/active_model_serializers/blob/0-10-stable/docs/general/adapters.md#json-api) for adapter-specific options.

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

### Swagger Documentation

Swagger generation is optional and provided by [grape-swagger](https://github.com/ruby-grape/grape-swagger), not by this gem. The third-party [grape-swagger-active_model_serializers](https://github.com/kawamoto/grape-swagger-active_model_serializers) gem registers an AMS model parser, analogous to the Entity and Representable integrations.

Add the documentation dependencies to your application's Gemfile:

```ruby
gem 'grape-active_model_serializers'
gem 'grape-swagger'
gem 'grape-swagger-active_model_serializers'
```

Load the parser before generating the documentation and identify the serializer as the endpoint's success model:

```ruby
require 'grape-active_model_serializers'
require 'grape-swagger-active_model_serializers'

class UserSerializer < ActiveModel::Serializer
  attributes :id, :name
end

class API < Grape::API
  format :json
  formatter :json, Grape::Formatter::ActiveModelSerializers

  desc 'Return a user', success: UserSerializer
  get '/users/:id' do
    render User.find(params[:id]), serializer: UserSerializer, adapter: :attributes
  end

  add_swagger_documentation
end
```

`GET /swagger_doc` returns the Swagger/OpenAPI 2.0 document with a generated definition for the serializer's attributes. `success: UserSerializer` selects the documentation model; it does not configure response serialization, so keep the runtime serializer and adapter consistent with the schema.

The example uses the `:attributes` adapter to match a flat object schema. A serializer definition alone does not describe a `:json` root envelope, JSON:API's `data`/`included` structure, or relationships. Attribute types depend on the parser's model metadata and untyped attributes may default to strings. Inspect the generated definitions and use [custom model parsers](https://github.com/ruby-grape/grape-swagger#custom-model-parsers) or explicit response models when your output needs a different schema.

The parser is maintained separately, brings its own dependencies, and is not required for normal serialization. Check its documentation and compatibility when choosing versions.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## History

Structured and based upon [grape-rabl](https://github.com/ruby-grape/grape-rabl).
