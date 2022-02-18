# frozen_string_literal: true

module Dry
  module PropCheck
    module Types
      include Dry.Types

      Cardinality = Types::Symbol.enum(:one, :many)

      # rubocop:disable Lint/BooleanSymbol
      AttributeType = Types::Symbol.enum(
        :integer,
        :nil,
        :symbol,
        :class,
        :true,
        :false,
        :bool,
        :float,
        :decimal,
        :string,
        :date,
        :date_time,
        :time,
        :any,
        :hash,
        :reference
      )
      # rubocop:enable Lint/BooleanSymbol
    end
  end
end
