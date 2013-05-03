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

require "#{Rails.root}/lib/behaviors/random_mover"

module Behaviors
  class RandomTester < Behaviors::RandomMover
    def initialize
      super
      @behavior_step = 0
      @was_running = false
    end

    def next_action
      next_action = nil
      if @agent.status == 'running'
        if not @was_running
          @behavior_step = 0
        end
        @was_running = true
        if @behavior_step % 2 == 0
          next_pos = get_next_pos
          Madmass.logger.warn "==[#{self}] GETTING POSTS NEAR TO #{next_pos[:latitude]}, #{next_pos[:longitude]}"
          next_action = get_nearby_posts_action next_pos
        else
          nearby_posts = Madmass.current_perception[0].data[:nearby_posts]
          if nearby_posts.empty?
            Madmass.logger.warn "==[#{self}] no post found nearby: nothing to do"
          else
            Madmass.logger.warn "==[#{self}] found #{nearby_posts.size} posts nearby"
            post = nearby_posts[rand(0..(nearby_posts.size-1))]
            Madmass.logger.warn "==[#{self}] randomly chosen this: #{post.inspect}"
            next_action = comment_post_action({ 
                :latitude => @current_pos[:latitude], 
                :longitude => @current_pos[:longitude],
                :post_id => post[:id]
            })
          end
        end
        @behavior_step += 1
      elsif @agent.status == 'stopped'
        @was_running = false
      end
      next_action
    end

    def last_wish
      nil
    end

    private

    def get_next_pos
      next_pos = @current_route[@position_in_route]
      @position_in_route += 1
      @current_route = nil if @current_route[@position_in_route].nil?
      @current_pos = next_pos
      next_pos
    end

    def get_nearby_posts_action opts
      lat = opts[:latitude].to_s.to_f + (0.5 - rand) * 0.1 
      lon = opts[:longitude].to_s.to_f + (0.5 - rand) * 0.1 
      result = {
        :cmd => "madmass::action::remote",
        :data => {
          :cmd => 'actions::get_nearby_posts',
          :sync => true,
          :latitude => lat,
          :longitude => lon,
          :max_count => 10,
          :max_dist => 10000,
          :user => { :id => @agent.id }
        }
      }

      Madmass.logger.warn "==[#{self}] created get nearby posts action: \n #{result.to_yaml}\n"
      return result
    end

    def comment_post_action opts
      lat = opts[:latitude].to_s.to_f
      lon = opts[:longitude].to_s.to_f
      post_id = opts[:post_id]
      result = {
        :cmd => "madmass::action::remote",
        :data => {
          :cmd => 'actions::comment_post',
          :latitude => lat,
          :longitude => lon,
          :post_id => post_id,
#          :data => {
#            :type => "Post",
#            :body => "Post from Blogger\n, Coordinates <#{lon},#{lat}>"
#         },
          :user => { :id => @agent.id }
        }
      }

      Madmass.logger.warn "==[#{self}] created comment post action: \n #{result.to_yaml}\n"
      return result
    end

    def like_post_action opts
      lat = opts[:latitude].to_s.to_f
      lon = opts[:longitude].to_s.to_f
      post_id = opts[:post_id]
      result = {
        :cmd => "madmass::action::remote",
        :data => {
          :cmd => 'actions::like_post',
          :latitude => lat,
          :longitude => lon,
          :post_id => post_id,
          :user => { :id => @agent.id }
        }
      }

      Madmass.logger.warn "==[#{self}] created like post action: \n #{result.to_yaml}\n"
      return result
    end

    def destroy_agent_params(opts = {})
      return {
        :cmd => "madmass::action::remote",
        :data => {
          :cmd => 'destroy_agent',
          :sync => true,
          :user => {:id => @agent.id}
        }.merge(opts)
      }
    end

  end
end
