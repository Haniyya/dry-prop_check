# frozen_string_literal: true

require_relative 'type_rule_compiler'
require_relative 'type_registry'
require_relative 'module_resolver'

module Dry
  module PropCheck
    class Compiler
      include ::PropCheck::Generators
      attr_reader :predicates

      @@compiler_cache = {}

      def initialize(predicates = ::Dry::PropCheck::Predicates)
        @max_recursion = 0
        @struct_stack = []
        @seen_structs = Set.new
        @predicates = predicates
      end

      def call(ast)
        visit(ast)
      end

      def visit(node)
        type, body = node
        puts "Visit #{type} with #{body.flatten.take(4).join(', ')}..."
        send(:"visit_#{type}", body)
      end

      def visit_constrained(node)
        nominal, rule = node
        rule = visit_rule(rule)
        visit(nominal).where { |obj| rule.call(obj) }
        # type.constrained_type.new(type, rule: visit_rule(rule))
      end

      def visit_constructor(node)
        nominal, fn = node
        primitive = visit(nominal)
        compiled_fn = compile_fn(fn)
        primitive.map(&compiled_fn)
      end

      def visit_nominal(node)
        type, _meta = node

        return module_generator(type) if !type.is_a?(Class) && type.is_a?(Module)

        predicates[[:type?, type]]
      end

      def non_recursive_impls(mod)
        ObjectSpace
          .each_object(Class)
          .select { |c| c < mod }
          .select { |c| c < Dry::Struct }
          .select { |c| @struct_stack.count { |m| m == c } <= @max_recursion }
      end

      def visit_rule(node)
        ::Dry::Logic::RuleCompiler.new(
          ::Dry::Logic::Predicates
        ).call([node])[0]
      end

      def visit_sum(node)
        *types, _meta = node
        generators = types.map { |type| visit(type) }
        one_of(*generators)
      end

      def visit_array(node)
        member, _meta = node
        member = case member
                 when Class then visit(Types.Instance(member).to_ast)
                 when Module
                   impls = non_recursive_impls(member)
                   return constant([]) if impls.empty?

                   one_of(*impls.map { |c| visit(c.to_ast) })
                 else visit(member)
                 end
        array(member, max: 5)
      end

      def visit_hash(node)
        reqs = []
        optionals = []
        opts, _meta = node

        opts.each_key { (key.to_s.end_with?('?') ? optionals : reqs) << key }
      end

      def visit_struct(node)
        struct, constructor = node
        @struct_stack << struct
        @@compiler_cache[struct] ||= instance(struct, visit(constructor)).tap { @struct_stack.pop }
      end

      def visit_schema(node)
        keys, _options, _meta = node
        key_generators = keys.map { |k| visit(k) }
        tuple(*key_generators).map(&:compact).map(&:to_h)
      end

      def visit_json_hash(node)
        keys, meta = node
        registry['json.hash'].schema(keys.map { |key| visit(key) }, meta)
      end

      def visit_json_array(node)
        member, meta = node
        registry['json.array'].of(visit(member)).meta(meta)
      end

      def visit_params_hash(node)
        keys, meta = node
        registry['params.hash'].schema(keys.map { |key| visit(key) }, meta)
      end

      def visit_params_array(node)
        member, meta = node
        registry['params.array'].of(visit(member)).meta(meta)
      end

      def visit_key(node)
        name, required, type = node
        gen = tuple(constant(name), visit(type))
        gen = nillable(gen) unless required
        gen
      end

      def visit_enum(node)
        _type, mapping = node
        one_of(*mapping.map { |k, v| one_of(constant(k), constant(v)) })
      end

      def visit_map(node)
        key_type, value_type, meta = node
        registry['nominal.hash'].map(visit(key_type), visit(value_type)).meta(meta)
      end

      def visit_any(_meta)
        predicates[[:type?, Object]]
      end

      def compile_fn(fn)
        type, *node = fn

        case type
        when :id
          Dry::Types::FnContainer[node.fetch(0)]
        when :callable
          node.fetch(0)
        when :method
          target, method = node
          target.method(method)
        else
          raise ArgumentError, "Cannot build callable from #{fn.inspect}"
        end
      end
    end
  end
end
