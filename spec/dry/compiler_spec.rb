# frozen_string_literal: true

require 'spec_helper'

module Dry
  module PropCheck
    RSpec.describe Compiler do
      describe '#visit' do
        let(:compiler) { described_class.new }

        def generates_valid_generator_for(type)
          generator = compiler.visit(type.to_ast)
          ::PropCheck.forall(generator) do |value|
            expect(value).to match(type)
          end
        end

        let(:struct) do
          Class.new(::Dry::Struct) do
            attribute :name, Types::String
            attribute :age, Types::Integer.optional
          end
        end

        let(:nested_struct) do
          Class.new(::Dry::Struct) do
            attribute :email, Types::String
            attribute :info, Info
          end
        end

        let(:recursive_struct) do
          mod = Module.new

          Class.new(::Dry::Struct) do
            include mod

            attribute :tail, Types::Array.of(mod)
          end
        end

        before do
          recursive_struct
          stub_const('Info', struct)
        end

        it { generates_valid_generator_for(Types::Strict::Any) }
        it { generates_valid_generator_for(Types::Strict::Nil) }
        it { generates_valid_generator_for(Types::Strict::Symbol) }
        it { generates_valid_generator_for(Types::Strict::Class) }
        it { generates_valid_generator_for(Types::Strict::True) }
        it { generates_valid_generator_for(Types::Strict::False) }
        it { generates_valid_generator_for(Types::Strict::Bool) }
        it { generates_valid_generator_for(Types::Strict::Integer) }
        it { generates_valid_generator_for(Types::Strict::Float) }
        it { generates_valid_generator_for(Types::Strict::Decimal) }
        it { generates_valid_generator_for(Types::Strict::String) }
        it { generates_valid_generator_for(Types::Strict::Date) }
        it { generates_valid_generator_for(Types::Strict::DateTime) }
        it { generates_valid_generator_for(Types::Strict::Time) }
        it { generates_valid_generator_for(Types::Strict::Array) }

        it { generates_valid_generator_for(Types::Strict::Integer.optional) }

        it { generates_valid_generator_for(Types::String.enum('yes', 'no')) }
        it { generates_valid_generator_for(Types::Integer.enum(3 => 1, 4 => 0)) }
        it { generates_valid_generator_for(Types::Integer | Types::String) }

        it { generates_valid_generator_for(Types::Array.of(Types::String)) }

        it { generates_valid_generator_for(Types::Hash.schema(name: Types::String, age?: Types::Integer)) }
        it { generates_valid_generator_for(struct) }
        it { generates_valid_generator_for(nested_struct) }

        it { generates_valid_generator_for(recursive_struct) }
      end
    end
  end
end
