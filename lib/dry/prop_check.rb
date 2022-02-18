# frozen_string_literal: true

require 'dry/struct'
require 'prop_check'

require 'dry/prop_check/schema_compiler'
require 'dry/prop_check/compiler'
require 'dry/prop_check/version'

module Dry
  module PropCheck
    module Types
      include Dry.Types
    end

    class Error < StandardError; end
    # Your code goes here...
  end
end
