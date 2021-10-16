module KDL
  module Types
    MAPPING = {}
  end
end

require 'kdl/types/date_time'
require 'kdl/types/duration'
require 'kdl/types/currency'
require 'kdl/types/country'
require 'kdl/types/ip'

KDL::Types::MAPPING.freeze
