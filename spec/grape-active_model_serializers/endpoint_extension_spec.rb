require 'spec_helper'

describe 'Grape::EndpointExtension' do
  if Grape::Util.const_defined?('InheritableSetting')
    subject { Grape::Endpoint.new(Grape::Util::InheritableSetting.new, path: '/', method: 'foo') }
  else
    subject { Grape::Endpoint.new({}, path: '/', method: 'foo') }
  end

  let(:serializer) { Grape::Formatter::ActiveModelSerializers }

  let(:user) do
    Object.new do
      def name
        'sven'
      end
    end
  end

  let(:users) { [user, user] }

  describe '#render' do
    before do
      allow(subject).to receive(:env).and_return({})
    end
    it { should respond_to(:render) }
    let(:meta_content) { { total: 2 } }
    let(:meta_full) { { meta: meta_content } }
    context 'supplying meta' do
      it 'passes through the Resource and uses given meta settings' do
        allow(subject).to receive(:env).and_return(meta: meta_full)
        expect(subject.render(users, meta_full)).to eq(users)
      end
    end
    context 'supplying meta and key' do
      let(:meta_key) { { meta_key: :custom_key_name } }
      it 'passes through the Resource and uses given meta settings' do
        allow(subject).to receive(:env).and_return(meta: meta_full.merge(meta_key))
        expect(subject.render(users, meta_full.merge(meta_key))).to eq(users)
      end
    end
  end
end
