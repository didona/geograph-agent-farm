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

ActiveSupport::Notifications.subscribe "madmass.command_sent"  do |name, start, finish, id, payload|
#  MessageCounter.instance.cmd_sent
end

ActiveSupport::Notifications.subscribe "geograph-generator.perception_received"  do |name, start, finish, id, payload|
#  MessageCounter.instance.percept_received
end

ActiveSupport::Notifications.subscribe "madmass.agent_queue_received"  do |name, start, finish, id, payload|
#  MessageCounter.instance.agent_queue_rcv
end

ActiveSupport::Notifications.subscribe "geograph-generator.agent_queue_sent"  do |name, start, finish, id, payload|
#  MessageCounter.instance.agent_queue_sent
end

