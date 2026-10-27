### Upgrading to v3.0.0

#### Explicit namespace roots apply to single objects

With the AMS `:json` adapter, an explicit namespace `root` now applies consistently to both collections and single objects. This intentionally changes single-object response keys that previously ignored the namespace root:

```ruby
namespace :users, root: 'members' do
  get('/')    { User.all }
  get('/:id') { User.find(params[:id]) }
end
```

The collection uses `{ "members": [...] }`. In 3.0 the single-object response also uses `"members"`, returning `{ "members": {...} }` rather than the previous `{ "user": {...} }`. Roots are literal: a single-object response does not automatically singularize `"members"`.

To preserve an existing single-object response key, override the namespace root on that route:

```ruby
namespace :users, root: 'members' do
  get '/:id', root: 'user' do
    User.find(params[:id])
  end
end
```

Alternatively, pass `root: 'user'` to `render` or remove the namespace root and specify collection roots on individual collection routes. Update API clients and response schemas if adopting the new namespace-derived key instead.

Root precedence is `render` > route > innermost explicit namespace root > outer namespace roots > default serializer options. Without an explicit root, single objects retain AMS model/serializer inference; collections retain the innermost namespace or route-name default.

The change is limited to explicit namespace roots. It does not change serializer inference, merge other namespace options differently, or alter adapter semantics. The `:attributes` adapter still omits envelopes, the `:json_api` adapter keeps its standard document structure, and `root: false` still does not remove a `:json` envelope.

### Upgrading to v1.5.0

#### ASM v0.10.x support added, v0.9.x support dropped

[ASM](https://github.com/rails-api/active_model_serializers) introduced
breaking changes with ASM v0.10.x. Support has been introduced in v1.5.0.
If you require support for older version of ASM, please lock your Gemfile
to the relevant version.

#### Non-collection Serializer Resolution

Serializer resolution now uses the following strategy:

1. Defined by the resource

```
class UsersApi < Grape::Api
  resource :users do
    get '/:id', serializer: SpecifiedUserSerializer do
      current_user
    end
  end
end

class User
  def serializer_class
    SpecifiedUserSerializer
  end
end
```

2. Specified by options

```
class UsersApi < Grape::Api
  resource :users do
    get '/:id', serializer: SpecifiedUserSerializer do
      current_user
    end
  end
end
```

2. Namespace inferred

```
class V1::UsersApi < Grape::Api
  resource :users do
    get '/:id' do
      current_user
    end
  end
end
# 'V1::UsersApi'.deconstantize => 'V1'
# searches for serializers in the V1:: namespace with the name UserSerializer

# used
class V1::UserSerializer
  ...
end

# not used since V1::UserSerializer resolved first
class UserSerializer
  ...
end
```

3. Version inferred

```
class UsersApi < Grape::Api
  version 'v2'

  resource :users do
    get '/:id' do
      current_user
    end
  end
end
# 'v2'.classify => V2
# searches for serializers in the V2:: namespace with the name UserSerializer

# used
class V2::UserSerializer
  ...
end

# not used since V2::UserSerializer resolved first
class UserSerializer
  ...
end
```

4. Default ASM lookup

```
class V1::UsersApi < Grape::Api
  version 'v2'

  resource :users do
    get '/:id' do
      current_user
    end
  end
end
# searches for serializers in the V1:: namespace, none found
# searches for serializers in the V2:: namespace, none found

# used as no other serializers were found
class UserSerializer
  ...
end
```

#### Collection Serializer Resolution

Serializer resolution for collections also uses the above strategy, but has
the added option of overriding the member serializer if the `each_serializer`
options is specified.

```
class UsersApi < Grape::Api
  resource :users do
    get each_serializer: SpecifiedUserSerializer do
      User.all
    end
  end
end
```


### Upgrading to v1.4.0

#### Changes in Serializer Namespacing

Version 1.4.0 introduced changes in serializer namespacing when using Grape
API versioning.

If you haven't declared an API version in Grape, nothing changed.

If your Grape API is versioned, which means you have declared at least one
version in Grape, you must namespace your serializers accordingly.

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

Namespace serializers according to each version.

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

This will allow you to keep your serializers easier to maintain and more
organized.

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

or alternatively:

```
└── serializers
    ├── chocolate_user_serializer.rb
    └── candy_bar_user_serializer.rb
```

Thus, ActiveModelSerializer will fetch automatically the right serializer to
render.

### Upgrading to v1.0.0

#### Changes to Array Roots

When serializing an array, the array root is set to the innermost namespace
name if there is one, otherwise it is set to the route name.

In the following example the array root is `users`.

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
