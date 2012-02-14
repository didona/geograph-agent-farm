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

module ApplicationHelper

  # Use this helper to regiter the client with the socky server. Put it
  # somewhere in the views. It accepts options in the form of:
  # {
  #   :channels => [array of channel identifiers],
  #   :client => client identifier
  # }
  # Channels are used to broadcast messages to everyone while client is
  # used to send private messges only to the client.
  def register_socky(options)
    if(!options.kind_of?(Hash) or (options[:channels].blank? and options[:client].blank?))
      raise Madmass::Errors::CatastrophicError, "Wrong socky registration: #{options.inspect}"
    end

    socky(:channels => options[:channels], :client_id => options[:client])

  end

end
