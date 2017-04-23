require 'spec_helper'

describe 'Grape::EndpointExtension' do
  if Grape::Util.const_defined?('InheritableSetting')
    subject do
      Grape::Endpoint.new(
        Grape::Util::InheritableSetting.new,
        path:   '/',
        method: 'foo'
      )
    end
  else
    subject do
      Grape::Endpoint.new({}, path: '/', method: 'foo')
    end
  end

  let(:serializer) { Grape::Formatter::ActiveModelSerializers }
  let(:user) {
    Object.new do
      def name
        'sven'
      end
    end
  }
  let(:users) { [user, user] }

  describe '#render' do
    let(:env) { {} }
    let(:env_key) {}

    before do
      allow(subject).to receive(:env).and_return(env)
    end

    shared_examples_for 'option capture' do
      it 'captures options' do
        subject.render(users, options)
        expect(env[env_key]).to eq(options)
      end
    end

    shared_examples_for 'skipped option capture' do
      it 'does not capture options' do
        subject.render(users, options)
        expect(env[env_key]).to eq({})
      end
    end

    it { should respond_to(:render) }

    context 'meta options' do
      let(:env_key) { 'ams_meta' }
      let(:meta_full) { { meta: meta_content } }

      context 'meta' do
        let(:options) { { meta: { total: 2 } } }
        it_behaves_like 'option capture'
      end

      context 'meta_key' do
        let(:options) { { meta_key: 'custom_meta' } }
        it_behaves_like 'option capture'
      end

      context 'unknown option' do
        let(:options) { { unknown: 'value' } }
        it_behaves_like 'skipped option capture'
      end
    end

    context 'adapter options' do
      let(:options) { {} }
      let(:env_key) { 'ams_adapter' }

      context 'adapter' do
        let(:options) { { adapter: :json } }
        it_behaves_like 'option capture'
      end

      context 'include' do
        let(:options) { { include: '*' } }
        it_behaves_like 'option capture'
      end

      context 'fields' do
        let(:options) { { fields: [:id] } }
        it_behaves_like 'option capture'
      end

      context 'key_transform' do
        let(:options) { { key_transform: :camel_lower } }
        it_behaves_like 'option capture'
      end

      context 'links' do
        let(:links_object) {
          {
            href: 'http://example.com/api/posts',
            meta: {
              count: 10
            }
          }
        }
        let(:options) { { links: links_object } }
        it_behaves_like 'option capture'
      end

      context 'namespace' do
        let(:options) { { namespace: V4 } }
        it_behaves_like 'option capture'
      end

      context 'unknown option' do
        let(:options) { { unknown: 'value' } }
        it_behaves_like 'skipped option capture'
      end
    end

    context 'extra options' do
      let(:env_key) { 'ams_extra' }

      context 'namespace' do
        let(:options) { { extra: { option: 'value' } } }

        it 'captures options' do
          subject.render(users, options)
          expect(env[env_key]).to eq(options[:extra])
        end
      end

      context 'unknown option' do
        let(:options) { { unknown: 'value' } }

        it 'does not capture options' do
          subject.render(users, options)
          expect(env[env_key]).to eq(nil)
        end
      end
    end
  end
end
