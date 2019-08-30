require 'spec_helper'

# asserts serializer resolution order:
#   1. resource_defined_class     # V1::UserSerializer
#   2. collection_class           # CollectionSerializer, V2::UserSerializer
#   3. options[:serializer]       # V3::UserSerializer
#   4. namespace_inferred_class   # V4::UserSerializer
#   5. version_inferred_class     # V5::UserSerializer
#   6. resource_serializer_class  # UserSerializer
#   7. missing resource           # nil

describe Grape::ActiveModelSerializers::SerializerResolver do
  let(:resolver) { described_class.new(resource, options) }
  let(:resource) { User.new }
  let(:options) {
    {
      serializer: options_serializer_class, # options defined
      for:        V4::UsersApi,             # namespace inference
      version:    'v5'                      # version inference
    }
  }
  # resource defined
  let(:resource_defined?) { true }
  let(:defined_serializer_class) { V1::UserSerializer }
  # options defined
  let(:options_serializer_class) { V3::UserSerializer }

  let(:serializer) { resolver.serializer }

  before do
    if resource_defined?
      allow(resource).to receive(:respond_to?).and_call_original
      allow(resource).to receive(:respond_to?).with(:to_ary) { true }
      allow(resource).to receive(:serializer_class) { defined_serializer_class }
    end
  end

  context 'resource defined' do
    it 'returns serializer' do
      expect(serializer).to be_kind_of(defined_serializer_class)
    end
  end

  context 'not resource defined' do
    let(:resource_defined?) { false }

    context 'resource collection' do
      let(:resource) { [User.new] }
      let(:serializer_class) { ActiveModel::Serializer::CollectionSerializer }

      it 'returns serializer' do
        expect(serializer).to be_kind_of(serializer_class)
      end

      context 'specified nil by options' do
        let(:options) {
          super().merge(
            serializer: nil
          )
        }

        it 'returns nil' do
          expect(serializer).to be_nil
        end
      end

      context 'each serializer' do
        let(:options) {
          super().except(:serializer).merge(
            each_serializer: V2::UserSerializer
          )
        }
        let(:each_serializer) { serializer.send(:options)[:serializer] }

        context 'each_serializer option' do
          it 'returns expected serializer' do
            expect(each_serializer).to eq(V2::UserSerializer)
          end
        end

        context 'no each_serializer option' do
          let(:options) { super().except(:each_serializer) }

          context 'namespace inferred' do
            it 'returns expected serializer' do
              expect(each_serializer).to eq(V4::UserSerializer)
            end
          end

          context 'not namespace inferred' do
            let(:options) { super().except(:for) }

            context 'version inferred' do
              it 'returns expected serializer' do
                expect(each_serializer).to eq(V5::UserSerializer)
              end
            end

            context 'not version inferred' do
              let(:options) { super().except(:version) }

              it 'returns nil' do
                expect(each_serializer).to eq(nil)
              end
            end
          end
        end
      end
    end

    context 'not resource collection' do
      context 'specified by options' do
        it 'returns specified serializer' do
          expect(serializer).to be_kind_of(V3::UserSerializer)
        end
      end

      context 'not specified by options' do
        let(:options) { super().except(:serializer) }

        context 'namespace inferred' do
          it 'returns inferred serializer' do
            expect(serializer).to be_kind_of(V4::UserSerializer)
          end
        end

        context 'not namespace inferred' do
          let(:options) { super().except(:for) }

          context 'version inferred' do
            it 'returns inferred serializer' do
              expect(serializer).to be_kind_of(V5::UserSerializer)
            end
          end

          context 'not version inferred' do
            let(:options) { super().except(:version) }

            context 'ASM resolved' do
              it 'returns serializer' do
                expect(serializer).to be_kind_of(UserSerializer)
              end
            end

            context 'not ASM resolved' do
              let(:resource) { nil }

              it 'returns nil' do
                expect(serializer).to eq(nil)
              end
            end
          end
        end
      end
    end
  end
end
