class BenchmarkSchedulesController < ApplicationController

  before_filter :get_schedule

  def update_iterations
    @schedule.iterations = params[:iterations]
    @schedule.save!
    render :layout => false
  end

  def set_benchmark
    profile = DynamicProfile.find(params[:profile])
    @schedule.dynamic_profiles << profile
    last_position = DynamicProfile.max_position(@schedule.id)
    profile.update_attribute(:position, last_position)
    render :layout => false
  end

  def play
    @schedule.active = true
    @schedule.save!
    render :layout => false
  end

  def stop
    @schedule.active = false
    @schedule.save!
    render :layout => false
  end

  def index
    unless current_user.benchmark_schedule
      current_user.benchmark_schedule = BenchmarkSchedule.create(:iterations => 1)
      current_user.save!
      get_schedule
    end
    @benchmarks = @schedule.dynamic_profiles || []
    @dynamic_profiles = current_user.dynamic_profiles
  end

  def remove_profile
    dynamic_profile = DynamicProfile.find(params[:profile])
    @schedule.dynamic_profiles.delete(dynamic_profile)
    render 'benchmarks', :layout => false
  end

  def sort
    params[:ids].each_with_index do |profile_id, index|
      dynamic_profile = DynamicProfile.find_by_id(profile_id)
      dynamic_profile.update_attribute(:position, index + 1) if dynamic_profile
    end
    render :nothing => true
  end

  private

   def get_schedule
     @schedule = current_user.benchmark_schedule
   end
end
