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
end
