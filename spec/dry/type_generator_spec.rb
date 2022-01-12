# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Dry::PropCheck::TypeGenerator do
  describe '#visit' do
    let(:compiler) { described_class.new }

    def generates_valid_generator_for(type)
      generator = compiler.visit(type.to_ast)
      PropCheck.forall(generator) do |value|
        expect(value).to match(type)
      end
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
  end
end
