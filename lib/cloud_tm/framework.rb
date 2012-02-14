###############################################################################
###############################################################################
#
# This file is part of GeoGraph Agent Farm.
#
# Copyright (c) 2012 Algorithmica Srl
#
# GeoGraph Agent Farm is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GeoGraph Agent Farm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with GeoGraph Agent Farm.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact us via email at info@algorithmica.it or at
#
# Algorithmica Srl
# Vicolo di Sant'Agata 16
# 00153 Rome, Italy
#
###############################################################################
###############################################################################

require 'java'

require File.join(Rails.root, 'lib', 'fenix', 'loader')

# Load the Cloud-TM Framework.
CLOUDTM_PATH = File.join(Rails.root, 'lib', 'cloud_tm') unless defined?(CLOUDTM_PATH)
CLOUDTM_JARS_PATH = File.join(CLOUDTM_PATH, 'jars') unless defined?(CLOUDTM_JARS_PATH)
CLOUDTM_MODELS_PATH = File.join(CLOUDTM_PATH, 'models') unless defined?(CLOUDTM_MODELS_PATH)

# Require all Cloud-TM and dependencies jars
Dir[File.join(CLOUDTM_JARS_PATH, '*.jar')].each{|jar|
  require jar
}
# Add jars path to the class path
$CLASSPATH << CLOUDTM_JARS_PATH

module CloudTm

  Init     = Java::OrgCloudtmFramework::Init
  TxSystem = Java::OrgCloudtmFramework::TxSystem
  Config   = Java::OrgCloudtmFramework::CloudtmConfig

  class Framework
    class << self

      def init(options)
        case options[:framework]
        when CloudTm::Config::Framework::FENIX
          Fenix::Loader.init(options)
        when CloudTm::Config::Framework::OGM
          Ogm::Loader.init(options)
        else
          raise "Cannot find CloudTM framework: #{options[:framework]}"
        end

      end

    end
  end

end

# TODO: make this step dynamic
# Load domain models
CloudTm::AgentGroup   = Java::ItAlgoGeographAgentfarmDomain::AgentGroup
CloudTm::Agent        = Java::ItAlgoGeographAgentfarmDomain::Agent
CloudTm::BloggerAgent        = Java::ItAlgoGeographAgentfarmDomain::BloggerAgent
CloudTm::ReaderAgent        = Java::ItAlgoGeographAgentfarmDomain::ReaderAgent
CloudTm::MovableAgent        = Java::ItAlgoGeographAgentfarmDomain::MovableAgent
CloudTm::Route        = Java::ItAlgoGeographAgentfarmDomain::Route
CloudTm::Position     = Java::ItAlgoGeographAgentfarmDomain::Position
DomainRoot            = Java::ItAlgoGeographAgentfarmDomain::Root

Dir[File.join(CLOUDTM_PATH, '*.rb')].each{|ruby|
  next if ruby.match(/framework\.rb/)
  require ruby
}

Dir[File.join(CLOUDTM_MODELS_PATH, '*.rb')].each{|model|
  require model
}
