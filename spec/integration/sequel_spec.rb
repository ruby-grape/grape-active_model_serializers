require 'sequel'
require 'spec_helper'

describe 'Sequel Integration' do
  before do
    DB = Sequel.sqlite unless defined?(DB)
    DB.create_table(:users) do
      primary_key :id
      String :name
    end
    ActiveModelSerializers.config.adapter = :json
    app.format :json
    app.formatter :json, Grape::Formatter::ActiveModelSerializers
  end

  after do
    DB.drop_table(:users)
    Object.send(:remove_const, :SequelUser)
    Object.send(:remove_const, :SequelUserSerializer)
  end

  let!(:model) {
    SequelUser = Class.new(Sequel::Model(:users)) do
      include ActiveModel::Serialization
      def self.model_name
        'User'
      end
    end
  }
  let!(:serializer) {
    SequelUserSerializer = Class.new(ActiveModel::Serializer) do
      attributes :id, :name
    end
  }
  let(:app) { Class.new(Grape::API) }

  context 'collection' do
    let!(:users) {
      [
        model.create(name: 'one'),
        model.create(name: 'two')
      ]
    }

    it 'renders' do
      app.get('/users') { render SequelUser.dataset }
      response = get '/users'
      expect(JSON.parse(response.body)).to eq(
        'users' => [
          { 'id' => 1, 'name' => 'one' },
          { 'id' => 2, 'name' => 'two' }
        ]
      )
    end
  end

  context 'member' do
    let!(:user) { model.create(name: 'name') }

    it 'renders' do
      app.get('/user/1') { render SequelUser.first }
      response = get '/user/1'
      expect(JSON.parse(response.body)).to eq(
        'user' => { 'id' => 1, 'name' => 'name' }
      )
    end
  end
end
