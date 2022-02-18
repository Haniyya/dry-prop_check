# frozen_string_literal: true

require 'spec_helper'

module Dry
  module PropCheck
    RSpec.describe ModuleResolver do
      describe '#visit' do
        let(:mod) do
          mod = Module.new
        end

        before do
          stub_const('GenericModule', mod)
          stub_const('GenericImpl', impl)
        end

        let(:impl) do
          Class.new(::Dry::Struct) do
            include GenericModule
            attribute :name, Types::String
          end
        end

        let(:non_recursive_struct) do
          Class.new(::Dry::Struct) do
            attribute :something, Types.Instance(GenericModule)
          end
        end

        let(:expected_non_recursive_struct) do
          Class.new(::Dry::Struct) do
            attribute :something, GenericImpl
          end
        end

        it 'expands a module to its implementing members' do
          expect(described_class.new.call(non_recursive_struct.to_ast)).to eq(expected_non_recursive_struct.to_ast)
        end
      end
    end
  end
end
