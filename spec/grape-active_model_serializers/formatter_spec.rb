require 'spec_helper'
require 'grape-active_model_serializers/formatter'

describe Grape::Formatter::ActiveModelSerializers do
  subject { Grape::Formatter::ActiveModelSerializers }
  it { should respond_to(:meta) }
  it { should respond_to(:meta=) }
  it { should respond_to(:meta_key) }
  it { should respond_to(:meta_key=) }

  context '#meta' do
    it 'will silently accept falsy input but return empty Hash' do
      subject.meta = nil
      expect(subject.meta).to eq({})
    end

    it 'will wrap valid input in the meta: {} wrapper' do
      subject.meta = { total: 2 }
      expect(subject.meta).to eq({ meta: { total: 2 } })
    end
  end

  context '#meta_key' do
    it 'will silently accept falsy input but return empty Hash' do
      subject.meta_key = nil
      expect(subject.meta_key).to eq({})
    end

    it 'will wrap valid input in the meta_key: {} wrapper' do
      subject.meta_key = :custom_key_name
      expect(subject.meta_key).to eq({ meta_key: :custom_key_name })
    end
  end

  describe '.fetch_serializer' do
    let(:user) { User.new(first_name: 'John') }

    if Grape::Util.const_defined?('InheritableSetting')
      let(:endpoint) { Grape::Endpoint.new(Grape::Util::InheritableSetting.new, {path: '/', method: 'foo'}) }
    else
      let(:endpoint) { Grape::Endpoint.new({}, {path: '/', method: 'foo'}) }
    end

    let(:env) { { 'api.endpoint' => endpoint } }

    before do
      def endpoint.current_user
        @current_user ||= User.new(first_name: 'Current user')
      end

      def endpoint.default_serializer_options
        { only: :only, except: :except }
      end
    end

    subject { described_class.fetch_serializer(user, env) }

    it { should be_a UserSerializer }

    it 'should have correct scope set' do
      expect(subject.scope.current_user).to eq(endpoint.current_user)
    end

    it 'should read default serializer options' do
      expect(subject.instance_variable_get('@only')).to eq([:only])
      expect(subject.instance_variable_get('@except')).to eq([:except])
    end
  end
end
