require 'spec_helper'
require 'grape-active_model_serializers/error_formatter'

describe Grape::ErrorFormatter::ActiveModelSerializers do
  subject { Grape::ErrorFormatter::ActiveModelSerializers }
  let(:backtrace) { ['Line:1'] }
  let(:options) { {} }
  let(:env) { { 'api.endpoint' => app.endpoints.first } }
  let(:original_exception) { StandardError.new('oh noes!') }

  let(:app) {
    Class.new(Grape::API) do |app|
      app.format :json
      app.formatter :json, Grape::Formatter::ActiveModelSerializers
      app.error_formatter :json, Grape::ErrorFormatter::ActiveModelSerializers

      app.namespace('space') do |ns|
        ns.get('/', root: false) do
          error!(message, 422)
        end
      end
    end
  }
  let(:foo) {
    Class.new {
      include ActiveModel::Model

      attr_accessor :name

      def initialize(attributes = {})
        super
        errors.add(:name, 'We don\'t like bears')
      end
    }
  }

  before do
    ActiveModel::Serializer.config.adapter = :json_api
  end

  after do
    ActiveModel::Serializer.config.adapter = :json
  end

  describe '#call' do
    context 'message is an activemodel' do
      let(:message) {
        foo.new(name: 'bar')
      }
      it 'formats the error' do
        result = subject
                 .call(message, backtrace, options, env, original_exception)
        json_hash = JSON.parse(result)

        expected_result = {
          'errors' => [
            {
              'source' => {
                'pointer' => '/data/attributes/name'
              },
              'detail' => 'We don\'t like bears'
            }
          ]
        }

        expect(json_hash == expected_result).to eq(true)
      end
    end

    context 'message is hash like' do
      let(:message) { { 'errors' => ['error'] } }
      it 'passes the message through' do
        result = subject
                 .call(message, backtrace, options, env, original_exception)
        json_hash = JSON.parse(result)

        expect(json_hash == message).to eq(true)
      end
    end

    context 'message is text' do
      let(:message) { 'error' }
      it 'wraps the error' do
        result = subject
                 .call(message, backtrace, options, env, original_exception)
        json_hash = JSON.parse(result)

        expect(json_hash == { 'error' => message }).to eq(true)
      end
    end
  end

  describe 'API validation errors' do
    let(:message) { foo.new(name: 'bar') }

    it 'returns a JSON:API error document with the requested HTTP status' do
      model = message
      app.helpers do
        define_method(:message) { model }
      end

      get '/space/'

      expect(last_response.status).to eq(422)
      expect(JSON.parse(last_response.body)).to eq(
        'errors' => [
          {
            'source' => { 'pointer' => '/data/attributes/name' },
            'detail' => 'We don\'t like bears'
          }
        ]
      )
    end
  end
end
