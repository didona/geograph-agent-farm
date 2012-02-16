# 
#  This file is part of GeoGraph Agent Farm.
# 
#  Copyright (c) 2010-2012  Algorithmica Srl
# 
#  GeoGraph Agent Farm is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
# 
#  GeoGraph Agent Farm distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
# 
#  You should have received a copy of the GNU Lesser General Public License
#  along with GeoGraph Agent Farm. If not, see <http://www.gnu.org/licenses/>.
# 
#  Contact us via email at info@algorithmica.it or at
# 
#  Algorithmica Srl
#  Vicolo di Sant'Agata 16
#  00153 Rome, Italy
# 

class AgentGroupRunner
  include Madmass::Transaction::TxMonitor
  
  def initialize(options = {})
    @options = options
  end

  # Starts the production
  def run
    tx_monitor do
      CloudTm::AgentGroup.all.each do |group|
        next if group.status != 'started'
        force = false
        to_run = false
        if group.last_execution
          last_exec_time = Time.at(group.last_execution.getTime/1000) + group.delay
          now = Time.now
          to_run = true if(last_exec_time <= now)
        else
          force = true
          to_run = true
        end
        
        group.start(:force => force) if to_run
      end
    end
  end
  
end
