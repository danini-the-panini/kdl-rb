module KDL
  module Types
    MAPPING = {}
  end
end

require 'kdl/types/date_time'
require 'kdl/types/duration'

KDL::Types::MAPPING.freeze
