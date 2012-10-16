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

require File.join(Rails.root, 'lib', 'cloud_tm', 'models', 'route_loader')

module CloudTm
  class Route
    include CloudTm::Model
    extend CloudTm::RouteLoader

    def destroy
      FenixFramework.getDomainRoot.getApp.removeRoutes(self)
    end

    class << self

      def find(oid)
        _oid = oid
        all.each do |route|
          return route if route.oid == _oid
        end
        return nil
      end

      def create_with_root attrs = {}, &block
        create_without_root(attrs) do |instance|
          instance.set_root FenixFramework.getDomainRoot.getApp
        end
      end

      alias_method_chain :create, :root

      def all
        FenixFramework.getDomainRoot.getApp.getRoutes
      end

    end
  end
end 