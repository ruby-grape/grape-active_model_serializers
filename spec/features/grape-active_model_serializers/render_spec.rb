require 'spec_helper'
require 'securerandom'

describe '#render' do
  let(:app) { Class.new(Grape::API) }

  before do
    ActiveModelSerializers.config.adapter = :json
    app.format :json
    app.formatter :json, Grape::Formatter::ActiveModelSerializers
  end

  describe 'default_serializer_options' do
    let(:resource) { User.new(first_name: 'Jane', last_name: 'Doe') }
    let(:query) { { fields: ['first_name'] } }
    let(:route_options) { {} }

    before do
      app.helpers do
        def default_serializer_options
          { fields: params[:fields] }
        end
      end
      app.params do
        optional :fields, type: [String]
      end
      model = resource
      app.get('/users', **route_options) { model }

      get '/users', query
    end

    it 'filters attributes using request-specific defaults' do
      expect(JSON.parse(last_response.body)).to eq(
        'user' => { 'first_name' => 'Jane' }
      )
    end

    context 'a collection' do
      let(:resource) { [super()] }

      it 'filters each resource without changing the collection root' do
        expect(JSON.parse(last_response.body)).to eq(
          'users' => [{ 'first_name' => 'Jane' }]
        )
      end
    end

    context 'no requested fields' do
      let(:query) { {} }

      it 'keeps all serializer attributes' do
        expect(JSON.parse(last_response.body)).to eq(
          'user' => { 'first_name' => 'Jane', 'last_name' => 'Doe' }
        )
      end
    end

    context 'route options' do
      let(:route_options) { { fields: [:last_name] } }

      it 'overrides the default field selection' do
        expect(JSON.parse(last_response.body)).to eq(
          'user' => { 'last_name' => 'Doe' }
        )
      end
    end
  end

  def get_resource_with(meta)
    url = "/#{SecureRandom.hex}"
    app.get(url) do
      render User.new(first_name: 'Jeff'), meta
    end
    get url
    JSON.parse last_response.body
  end

  context 'with meta key' do
    it 'includes meta key and content' do
      result = get_resource_with(meta: { total: 2 })
      expect(result).to have_key('meta')
      expect(result.fetch('meta')).to eq('total' => 2)
    end
  end

  context 'with a custom meta_key' do
    it 'includes the custom meta key name' do
      result = get_resource_with(meta: { total: 2 }, meta_key: :custom_key_name)
      expect(result).to have_key('custom_key_name')
      expect(result.fetch('custom_key_name')).to eq('total' => 2)
    end

    it 'ignores a lonely meta_key' do
      result = get_resource_with(meta_key: :custom_key_name)
      expect(result).not_to have_key('meta')
      expect(result).not_to have_key('custom_key_name')
    end
  end

  context 'junk keys' do
    it 'ignores junk keys' do
      result = get_resource_with(junk_key: { total: 2 })
      expect(result).not_to have_key('junk_key')
    end

    it 'ignores empty meta_key' do
      result = get_resource_with(meta: { total: 2 }, meta_key: nil)
      expect(result).to have_key('meta')
    end

    it 'ignores empty meta' do
      result = get_resource_with(meta: nil)
      expect(result).not_to have_key('meta')
    end
  end
end

describe 'single-object and collection roots' do
  let(:app) { Class.new(Grape::API) }
  let(:resources) { [User.new(first_name: 'Jane', last_name: 'Doe')] }
  let(:outer_namespace_options) { { root: 'directory_members' } }
  let(:inner_namespace_options) { { root: 'members' } }
  let(:route_options) { {} }
  let(:render_options) { {} }

  before do
    ActiveModelSerializers.config.adapter = :json
    app.format :json
    app.formatter :json, Grape::Formatter::ActiveModelSerializers

    resource = resources
    options = render_options
    route_settings = route_options
    outer_options = outer_namespace_options
    inner_options = inner_namespace_options
    app.namespace :directory, **outer_options do
      namespace :users, **inner_options do
        get '/people', **route_settings do
          render resource, options
        end
      end
    end

    get '/directory/users/people'
  end

  it 'uses the innermost namespace root' do
    expect(JSON.parse(last_response.body)).to eq(
      'members' => [{ 'first_name' => 'Jane', 'last_name' => 'Doe' }]
    )
  end

  context 'route options' do
    let(:route_options) { { root: 'recent_members' } }

    it 'overrides the namespace root' do
      expect(JSON.parse(last_response.body)).to eq(
        'recent_members' => [{ 'first_name' => 'Jane', 'last_name' => 'Doe' }]
      )
    end
  end

  context 'render options' do
    let(:route_options) { { root: 'recent_members' } }
    let(:render_options) { { root: 'selected_members' } }

    it 'overrides the route and namespace roots' do
      expect(JSON.parse(last_response.body)).to eq(
        'selected_members' => [{ 'first_name' => 'Jane', 'last_name' => 'Doe' }]
      )
    end

    context 'an empty collection' do
      let(:resources) { [] }

      it 'keeps the explicit root' do
        expect(JSON.parse(last_response.body)).to eq('selected_members' => [])
      end
    end
  end

  context 'root is false' do
    let(:render_options) { { root: false } }

    it 'uses the AMS-inferred root rather than removing the JSON envelope' do
      expect(JSON.parse(last_response.body)).to eq(
        'users' => [{ 'first_name' => 'Jane', 'last_name' => 'Doe' }]
      )
    end
  end

  context 'the attributes adapter' do
    let(:render_options) { { adapter: :attributes, root: 'ignored' } }

    it 'returns a bare array regardless of the root option' do
      expect(JSON.parse(last_response.body)).to eq(
        [{ 'first_name' => 'Jane', 'last_name' => 'Doe' }]
      )
    end
  end

  context 'a single object' do
    let(:resources) { User.new(first_name: 'Jane', last_name: 'Doe') }

    it 'uses the same explicit namespace root as collections' do
      expect(JSON.parse(last_response.body)).to eq(
        'members' => { 'first_name' => 'Jane', 'last_name' => 'Doe' }
      )
    end

    context 'an inner namespace without a root' do
      let(:inner_namespace_options) { {} }

      it 'inherits the outer namespace root' do
        expect(JSON.parse(last_response.body)).to eq(
          'directory_members' => { 'first_name' => 'Jane', 'last_name' => 'Doe' }
        )
      end
    end

    context 'no explicit namespace roots' do
      let(:outer_namespace_options) { {} }
      let(:inner_namespace_options) { {} }

      it 'keeps the inferred model root' do
        expect(JSON.parse(last_response.body)).to eq(
          'user' => { 'first_name' => 'Jane', 'last_name' => 'Doe' }
        )
      end
    end

    context 'an inner namespace root is false' do
      let(:inner_namespace_options) { { root: false } }

      it 'uses the AMS-inferred root instead of inheriting the outer root' do
        expect(JSON.parse(last_response.body)).to eq(
          'user' => { 'first_name' => 'Jane', 'last_name' => 'Doe' }
        )
      end
    end

    context 'the attributes adapter' do
      let(:render_options) { { adapter: :attributes } }

      it 'keeps the response unwrapped despite the namespace root' do
        expect(JSON.parse(last_response.body)).to eq(
          'first_name' => 'Jane', 'last_name' => 'Doe'
        )
      end
    end

    context 'route options' do
      let(:route_options) { { root: 'person' } }

      it 'honors an explicit route root' do
        expect(JSON.parse(last_response.body)).to eq(
          'person' => { 'first_name' => 'Jane', 'last_name' => 'Doe' }
        )
      end
    end

    context 'render options' do
      let(:route_options) { { root: 'person' } }
      let(:render_options) { { root: 'selected_person' } }

      it 'overrides the route root' do
        expect(JSON.parse(last_response.body)).to eq(
          'selected_person' => { 'first_name' => 'Jane', 'last_name' => 'Doe' }
        )
      end
    end
  end
end
