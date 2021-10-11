module KDL
  module Types
    MAPPING = {}
  end
end

require 'kdl/types/date_time'
require 'kdl/types/duration'
require 'kdl/types/currency'

KDL::Types::MAPPING.freeze
