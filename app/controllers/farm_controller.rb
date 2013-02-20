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

class FarmController < ApplicationController
  before_filter :authenticate_agent
  respond_to :js, :html

  around_filter :transact, :only => [:console, :benchmark_tool]

  def index
    @agent = Madmass.current_agent
  end

  def update_profile
    current_user.current_profile = DynamicProfile.find_by_id params[:current_profile_id]
    current_user.save!
    Rails.logger.info("updating profile #{params[:current_profile_id]}")
    render :layout => false
  end

  def delete_profile
    current_user.current_profile.delete if current_user.current_profile
    current_user.current_profile = nil
    current_user.save!
    render :layout => false
  end

  def benchmark
    @agent_groups = CloudTm::AgentGroup.all
    @agent_groups.map(&:getAgents).flatten.each { |el| logger.debug el.inspect }
    @agent_group = CloudTm::AgentGroup.new
  end

  def add_static_profile
    @agent_groups = CloudTm::AgentGroup.all
    @static_profile = StaticProfile.create(:duration => params[:duration])
    @static_profile.dynamic_profile_id = current_user.current_profile_id
    @static_profile.move_to_bottom

    @agent_groups.each do |g|
      group = AgentGroup.create(:simulator => g.agents_type, :sleep => g.delay, :threads => g.agents.size)
      group.static_profile_id = @static_profile.id
      group.save!
    end
    @static_profile.save!
    render :layout => false
    #current_user.current_profile.static_profiles << static_profile #FIXME ACTS AS LIST
  end


  def console
    @agent_groups = CloudTm::AgentGroup.all
    @agent_groups.map(&:getAgents).flatten.each { |el| logger.debug el.inspect }
    @agent_group = CloudTm::AgentGroup.new
    @dynamic_profile = DynamicProfile.new

    @user = current_user
    @profiles = []
    if current_user.current_profile
      @profiles << [current_user.current_profile.name, current_user.current_profile.id]
    end
    current_user.dynamic_profiles.each do |p|
      @profiles << [p.name, p.id] unless (p == current_user.current_profile)
    end

  end

  def choose_process
    options = {}
    options[:name] = params[:id] if params[:id]
    options[:distance] = params[:distance] if params[:distance]
    Job.new.set(options)
  end

  private


  def transact
    CloudTm::FenixFramework.getTransactionManager.withTransaction do
      yield
    end
  end


end

