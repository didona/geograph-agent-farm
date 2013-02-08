###############################################################################
###############################################################################
#
# This file is part of GeoGraph.
#
# Copyright (c) 2012 Algorithmica Srl
#
# GeoGraph is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# GeoGraph is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with GeoGraph.  If not, see <http://www.gnu.org/licenses/>.
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


# Load the Cloud-TM Framework.
CLOUDTM_PATH = File.join(Rails.root, 'lib', 'cloud_tm') unless defined?(CLOUDTM_PATH)
CLOUDTM_JARS_PATH = File.join(CLOUDTM_PATH, 'jars') unless defined?(CLOUDTM_JARS_PATH)
CLOUDTM_MODELS_PATH = File.join(CLOUDTM_PATH, 'models') unless defined?(CLOUDTM_MODELS_PATH)
CLOUDTM_CONF_PATH = File.join(CLOUDTM_PATH, 'conf') unless defined?(CLOUDTM_CONF_PATH)

# Require all Cloud-TM and dependencies jars
Dir[File.join(CLOUDTM_JARS_PATH, '*.jar')].each { |jar|
  require jar
}
# Add jars path to the class path
$CLASSPATH << CLOUDTM_JARS_PATH
$CLASSPATH << CLOUDTM_CONF_PATH

module CloudTm

  #Init = Java::OrgCloudtmFramework::Init
  FenixFramework = Java::PtIstFenixframework::FenixFramework
  #Config = Java::OrgCloudtmFramework::CloudtmConfig

  class Framework
    class << self

      def init
        Madmass.transaction do
          root = FenixFramework.getDomainRoot()
          app = root.getApp()
          unless app
            app = CloudTm::Root.new
            root.setApp(app)
          end
        end
      end

    end
  end
end

# TODO: make this step dynamic
# Load domain models

CloudTm::DefaultExecutorService = Java::OrgInfinispanDistexec::DefaultExecutorService
CloudTm::AgentGroup = Java::ItAlgoGeographAgentfarmDomain::AgentGroup
CloudTm::Agent = Java::ItAlgoGeographAgentfarmDomain::Agent
CloudTm::BloggerAgent = Java::ItAlgoGeographAgentfarmDomain::BloggerAgent
CloudTm::ReaderAgent = Java::ItAlgoGeographAgentfarmDomain::ReaderAgent
CloudTm::MovableAgent = Java::ItAlgoGeographAgentfarmDomain::MovableAgent
CloudTm::Route = Java::ItAlgoGeographAgentfarmDomain::Route
CloudTm::Position = Java::ItAlgoGeographAgentfarmDomain::Position
CloudTm::Root = Java::ItAlgoGeographAgentfarmDomain::Root
CloudTm::DefTask= Java::ItAlgoGeographAgentfarm::RubyCallable


Dir[File.join(CLOUDTM_PATH, '*.rb')].each { |ruby|
  next if ruby.match(/framework\.rb/)
  require ruby
}

Dir[File.join(CLOUDTM_MODELS_PATH, '*.rb')].each { |model|
  require model
}
