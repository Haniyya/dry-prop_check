# frozen_string_literal: true

require 'set'
require_relative 'types'
require_relative 'compiler'

module Dry
  module PropCheck
    class Reference
    end

    class SchemaCompiler < Compiler
      class Attribute < ::Dry::Struct
        attribute :struct, Types::String
        attribute :name, Types::Symbol
        attribute :type, Types.Instance(::PropCheck::Generator)
        attribute :cardinality, Types::Cardinality
      end

      def schema
        @schema ||= Set.new
      end

      def call(ast)
        visit(ast)
        schema
      end

      def visit(node)
        type, body = node
        puts "Visit #{type} with #{body.flatten.take(4).join(', ')}..."
        send(:"visit_#{type}", body)
      end

      def visit_array(node)
        member, _meta = node
        visit(member)
      end

      def visit_struct(node)
        struct, constructor = node
        visit(constructor).each { |attr| schema << Attribute.new(struct: struct.to_s, **attr) }
      end

      def visit_schema(node)
        keys, _options, _meta = node
        keys.map { |k| visit(k) }
      end

      def visit_key(node)
        name, _required, type = node
        {
          name: name,
          type: super,
          cardinality: type.first == :array ? :many : :one
        }
      end
    end
  end
end
