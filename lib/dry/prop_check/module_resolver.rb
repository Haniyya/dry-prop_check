# frozen_string_literal: true

module Dry
  module PropCheck
    class ModuleResolver
      def call(ast)
        visit(ast)
      end

      def visit(node)
        type, body = node
        puts "Visit #{type} with #{body.flatten.take(4).join(', ')}..."
        visitor = :"visit_#{type}"

        if respond_to? visitor
          [type, send(:"visit_#{type}", body)]
        else
          node
        end
      end

      def visit_constructor(node)
        nominal, fn = node
        [visit(nominal), fn]
      end

      def visit_struct(node)
        struct, constructor = node
        struct_stack << struct
        [struct, visit(constructor)].tap { @struct_stack.pop }
      end

      def visit_constrained(node)
        nominal, rule = node
        [visit(nominal), rule]
      end

      def visit_nominal(node)
        type, meta = node
        return [expand_module(type), meta] if !type.is_a?(Class) && type.is_a?(Module)

        [visit(type), meta]
      end

      def expand_module(mod)
        impls = ObjectSpace
                .each_object(Class)
                .select { |c| c < mod }
                .select { |c| c < Dry::Struct }
                .select { |c| struct_stack.count { |m| m == c } <= recursion_limit }
        puts "Impls: '#{impls.join(', ')}'"
        if impls.count == 1
          impls.first.to_ast
        else
          [:sum, *impls.map(&:to_ast)]
        end
      end

      def visit_schema(node)
        keys, options, meta = node
        [keys.map { |k| visit(k) }, options, meta]
      end

      def visit_key(node)
        name, required, type = node
        [name, required, visit(type)]
      end

      def recursion_limit
        5
      end

      def struct_stack
        @struct_stack ||= []
      end
    end
  end
end
