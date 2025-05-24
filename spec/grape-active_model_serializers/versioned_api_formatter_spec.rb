require 'spec_helper'
require 'grape-active_model_serializers/formatter'

describe Grape::Formatter::ActiveModelSerializers do
  describe 'with a versioned API' do
    subject { Grape::Formatter::ActiveModelSerializers }

    describe 'serializer options from namespace' do
      let(:app) { Class.new(Grape::API) }

      before do
        app.format :json
        app.formatter :json, Grape::Formatter::ActiveModelSerializers
        app.version 'v1', using: :param

        app.namespace('space') do |ns|
          ns.get('/', root: false, apiver: 'v1') do
            {
              user: {
                first_name: 'JR',
                last_name: 'HE',
                email: 'jrhe@github.com'
              }
            }
          end
        end
      end

      let(:env) { { 'api.endpoint' => app.endpoints.first } }
      let(:options) { described_class.build_options(nil, env) }

      it 'should read serializer options like "root"' do
        expect(options).to include(:root)
      end
    end

    describe '.fetch_serializer' do
      let(:user) { User.new(first_name: 'John', email: 'j.doe@internet.com') }

      let(:params) { { path: '/', method: 'foo', version: 'v1', root: false } }
      if Grape::Util.const_defined?('InheritableSetting')
        let(:setting) { Grape::Util::InheritableSetting.new }
      else
        let(:setting) { {} }
      end
      let(:endpoint) { Grape::Endpoint.new(setting, params) }
      let(:env) { { 'api.endpoint' => endpoint } }

      before do
        def endpoint.current_user
          @current_user ||= User.new(first_name: 'Current user')
        end

        def endpoint.default_serializer_options
          { only: :only, except: :except }
        end
      end

      let(:options) { described_class.build_options(user, env) }
      subject { described_class.fetch_serializer(user, options) }

      let(:instance_options) { subject.send(:instance_options) }

      it { should be_a V1::UserSerializer }

      it 'should have correct scope set' do
        expect(subject.scope.current_user).to eq(endpoint.current_user)
      end

      it 'should read default serializer options' do
        expect(instance_options[:only]).to eq(:only)
        expect(instance_options[:except]).to eq(:except)
      end

      it 'should read serializer options like "root"' do
        expect(options).to include(:root)
      end
    end
  end
end
