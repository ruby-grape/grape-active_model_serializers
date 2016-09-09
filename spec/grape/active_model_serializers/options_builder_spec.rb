require 'spec_helper'

describe Grape::ActiveModelSerializers::OptionsBuilder do
  let(:resolver) { described_class.new(resource, env) }
  let(:resource) { User.new }
  let(:env) { { 'api.endpoint' => UsersApi.endpoints.first } }

  context '#options' do
    let(:options) { resolver.options }

    context 'meta options' do
      let(:env) { super().merge('ams_meta' => meta_options) }
      let(:meta_options) {
        {
          meta:     meta,
          meta_key: meta_key
        }
      }
      let(:meta) { { sample: 'metadata' } }
      let(:meta_key) { 'specified_key' }

      context 'meta option set' do
        context 'meta_key set' do
          it 'includes meta' do
            expect(options[:meta]).to eq(meta)
          end

          it 'includes meta_key' do
            expect(options[:meta_key]).to eq(meta_key)
          end
        end

        context 'meta_key unset' do
          let(:meta_key) { nil }

          it 'includes meta' do
            expect(options[:meta]).to eq(meta)
          end

          it 'does not include meta_key' do
            expect(options.keys).not_to include(:meta_key)
          end
        end
      end

      context 'meta option unset' do
        let(:meta) { nil }

        context 'meta_key set' do
          it 'does not include meta' do
            expect(options.keys).not_to include(:meta)
          end

          it 'does not include meta_key' do
            expect(options.keys).not_to include(:meta_key)
          end
        end

        context 'meta_key unset' do
          let(:meta_key) { nil }

          it 'does not include meta' do
            expect(options.keys).not_to include(:meta)
          end

          it 'does not include meta_key' do
            expect(options.keys).not_to include(:meta_key)
          end
        end
      end
    end

    context 'adapter options' do
      let(:env) { super().merge('ams_adapter' => adapter_options) }
      let(:adapter_options) { {} }

      context 'adapter' do
        let(:adapter_options) { { adapter: adapter } }
        let(:adapter) { :attributes }

        it 'includes adapter as top-level option' do
          expect(options[:adapter]).to eq(adapter)
        end
      end

      context 'serializer' do
        let(:adapter_options) { { serializer: serializer } }
        let(:serializer) { V2::UserSerializer }

        it 'includes serializer as top-level option' do
          expect(options[:serializer]).to eq(serializer)
        end
      end

      context 'each_serializer' do
        let(:adapter_options) { { each_serializer: each_serializer } }
        let(:each_serializer) { V2::UserSerializer }

        it 'includes each_serializer as top-level option' do
          expect(options[:each_serializer]).to eq(each_serializer)
        end
      end
    end

    context 'extra options' do
      let(:env) { super().merge('ams_extra' => extra_options) }

      context 'hash' do
        let(:extra_options) { { extra: 'info' } }

        it 'includes extra options in top-level options' do
          expect(options.keys).to include(:extra)
        end
      end

      context 'not a hash' do
        let(:extra_options) { 'extra' }

        it 'raises an exception' do
          expect {
            options
          }.to raise_exception(
            'Extra options must be a hash'
          )
        end
      end
    end
  end
end
