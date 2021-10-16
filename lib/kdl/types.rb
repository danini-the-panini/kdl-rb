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
require 'kdl/types/url'
require 'kdl/types/uuid'
require 'kdl/types/regex'
require 'kdl/types/base64'

KDL::Types::MAPPING.freeze
