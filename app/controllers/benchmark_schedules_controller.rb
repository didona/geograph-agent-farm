class BenchmarkSchedulesController < ApplicationController

  before_filter :get_schedule

  def update_iterations
    @schedule.iterations = params[:iterations]
    @schedule.save!
    render :layout => false
  end

  def set_benchmark
    profile = DynamicProfile.where(:name => params[:schedule_name])
    if(profile.length !=1)
     @errors = "multiple benchmarks with name #{params[:schedule_name]}"
    end
    profile = profile.first
    Rails.logger.debug "+++++++PROFILE #{profile.inspect}"
    profile.benchmark_schedule_id= @schedule.id
    profile.save!
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
    end
    @benchmarks = @schedule.dynamic_profiles || []
    @dynamic_profiles = current_user.dynamic_profiles

  end

  private
     def get_schedule
       @schedule = current_user.benchmark_schedule
     end
end
