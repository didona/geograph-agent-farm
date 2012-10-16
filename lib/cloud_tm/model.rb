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

module CloudTm
  module Model

    def self.included(base)
      base.extend ClassMethods
      # ActionView::Helpers compliance
      base.extend ActiveModel::Naming
      base.send(:include, ActiveModel::Serialization)
      base.send(:include, ActiveModel::Conversion)
    end

    module ClassMethods

      def where(options = {})
        instances = []
        all.each do |instance|
          instances << instance if instance.has_properties?(options)
        end
        return instances
      end


      def create(attrs = {}, &block)
        instance = new
        attrs.each do |attr, value|
          instance.send("#{attr}=", value)
        end
        block.call(instance) if block_given?
        instance
      end

    end

    def id #FIXME
      oid
    end

    def update_attributes attrs = {}
      attrs.each do |property, value|
        send("#{property}=", value)
      end
    end

    def update_attribute(attr, value)
      send("#{attr}=", value)
    end

    # Dummy method for ActionView::Helpers
    def persisted?
      false
    end

    def has_properties?(options)
      options.each do |prop, value|
        return false if send(prop) != value
      end
      true
    end

    private



  end
end