# frozen_string_literal: true

require 'spec_helper'

module Dry
  module PropCheck
    RSpec.describe SchemaCompiler do
      describe '#visit' do
        subject { compiler.visit(target.to_ast).to_a }

        let(:compiler) { described_class.new }

        let(:struct) do
          Class.new(::Dry::Struct) do
            attribute :name, Types::String
            attribute :age, Types::Integer.optional
          end.tap { |c| stub_const('Info', c) }
        end

        let(:nested_struct) do
          Class.new(::Dry::Struct) do
            attribute :email, Types::String
            attribute :info, Info
          end
        end

        context 'with a simple struct' do
          let(:target) { struct }
          let(:expected_attributes) do
            [
              described_class::Attribute.new(struct: 'Info', name: :name, type: :string, cardinality: :one),
              described_class::Attribute.new(struct: 'Info', name: :age, type: :integer, cardinality: :one)
            ]
          end

          it { is_expected.to match_array(expected_attributes) }
        end
      end
    end
  end
end
