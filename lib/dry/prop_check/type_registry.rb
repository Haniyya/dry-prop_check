# frozen_string_literal: true

module Dry
  module PropCheck
    class TypeRegistry
      class << self
        include ::PropCheck::Generators

        def [](name)
          public_send(name)
        end

        def type(type)
          case type
          when eq(Integer) then integer
          when eq(NilClass) then constant(nil)
          when eq(Symbol) then simple_symbol
          when eq(Class) then constant(Class.new)
          when eq(TrueClass) then constant(true)
          when eq(FalseClass) then constant(false)
          when eq(Float) then float
          when eq(BigDecimal) then float.map(&:to_s).map { |f| BigDecimal(f) }
          when eq(String) then string
          when eq(Date) then date_time_vals.map do |hash|
                               hash.values_at(:year, :month, :day)
                             end.map { |vals| Date.new(*vals) }
          when eq(DateTime) then date_time_vals.map do |hash|
                                   DateTime.new(*hash.values_at(:year, :month, :day, :hour, :minute, :second))
                                 end
          when eq(Time) then date_time_vals.map do |hash|
                               Time.new(*hash.values_at(:year, :month, :day, :hour, :minute, :second))
                             end
          when eq(Array) then array(any)
          when eq(Hash) then hash(any, any)
          else raise("unregistered type generator #{type}")
          end
        end

        private def date_time_vals
          fixed_hash(
            {
              year: choose(1..10_000),
              month: choose(1..12),
              day: choose(1..28),
              hour: choose(0..23),
              minute: choose(0..59),
              second: choose(0..59)
            }
          )
        end

        def any
          nillable(
            one_of(
              string, simple_symbol, integer, float, array(float)
            )
          )
        end

        def eq(a)
          ->(b) { a == b }
        end
      end
    end
  end
end
