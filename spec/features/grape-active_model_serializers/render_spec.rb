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
