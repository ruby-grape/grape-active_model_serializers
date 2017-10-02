require 'spec_helper'
require 'grape-active_model_serializers/error_formatter'
require 'pry'

describe Grape::ErrorFormatter::ActiveModelSerializers do
  subject { Grape::ErrorFormatter::ActiveModelSerializers }
  let(:backtrace) { ['Line:1'] }
  let(:options) { Hash.new }
  let(:env) { { 'api.endpoint' => app.endpoints.first } }
  let(:original_exception) { StandardError.new('oh noes!') }

  let(:app) { Class.new(Grape::API) }

  before do
    ActiveModel::Serializer.config.adapter = :json_api
    app.format :json
    app.formatter :jsonapi, Grape::Formatter::ActiveModelSerializers
    app.error_formatter :jsonapi, Grape::ErrorFormatter::ActiveModelSerializers

    app.namespace('space') do |ns|
      ns.get('/', root: false) do
        error!(message)
      end
    end
  end

  describe '#call' do
    context 'message is an activemodel' do
      let(:message) {
        class Foo
          include ActiveModel::Model
          attr_accessor :name
          def initialize(attributes = {})
            super
            errors.add(:name, 'We don\'t like bears')
          end
        end
        Foo.new(name: 'bar')
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
end
