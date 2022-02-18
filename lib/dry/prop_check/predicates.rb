# frozen_string_literal: true

require_relative 'generators'

module Dry
  module PropCheck
    class Predicates
      class << self
        def generators
          @generators ||= {}
        end

        def generator(predicate, &block)
          generators[predicate] = block
        end

        def type_generator(type, &block)
          generator([:type?, type], &block)
        end

        def [](predicate)
          generators[predicate].call
        end
      end

      extend ::PropCheck::Generators
      extend ::Dry::PropCheck::Generators

      type_generator(Integer)    { integer }
      type_generator(NilClass)   { constant(nil) }
      type_generator(Symbol)     { simple_symbol }
      type_generator(Class)      { one_of(*ObjectSpace.each_object(Class).map { |c| constant(c) }) }
      type_generator(TrueClass)  { constant(true) }
      type_generator(FalseClass) { constant(false) }
      type_generator(Float)      { float }
      type_generator(BigDecimal) { float.map(&:to_s).map(&Kernel.method(:BigDecimal)) }
      type_generator(String)     { printable_ascii_string }
      type_generator(Array)      { array(any, max: 5) }
      type_generator(Hash)       { hash_of(one_of(string, simple_symbol), any) }
      type_generator(Date)       { dates }
      type_generator(DateTime)   { date_times }
      type_generator(Time)       { times }
      type_generator(Object)     { any }
    end
  end
end
