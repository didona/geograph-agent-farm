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


class CommandsController < ApplicationController
  protect_from_forgery

  respond_to :json, :html

  include ApplicationHelper
  include ActionView::Helpers::JavaScriptHelper

  #before_filter :authenticate_agent

  def execute
      return unless params[:agent]
      Madmass.current_agent = GeoAgent.first || GeoAgent.create
      status = Madmass.current_agent.run(params[:agent])
      @perception = Madmass.current_perception
      
    respond_to do |format|
      format.html {render :execute, :status => status}
      format.json {
        #render :json => @perception.to_json, :status => status
        render :json => "ciao".to_json, :status => status
      }
    end
 
 rescue Madmass::Errors::StateMismatchError
    # redirect_to :action => current_user.state
 
 end



end

