class BenchmarkSchedulesController < ApplicationController
  before_filter :authenticate_agent
  before_filter :get_schedule

  def update_iterations
    @schedule.iterations = params[:iterations]
    @schedule.save!
    render :nothing => true
  end

  def update_profile_iterations
    @profile = DynamicProfile.find(params[:profile])
    @profile.update_attribute(:iterations, params[:iterations])
    render :nothing => true
  end

  def set_benchmark
    profile = DynamicProfile.find(params[:profile])
    @schedule.dynamic_profiles << profile
    last_position = DynamicProfile.max_position(@schedule.id)
    profile.update_attribute(:position, last_position)
    @progress_data = @schedule.progress_data
    render :layout => false
  end

  def play
    @active_schedules = BenchmarkSchedule.where("active = :active AND id <> :id", { :active => true, :id => @schedule.id })
    if @active_schedules.any?
      flash.now[:error] = "There are benchmarks already running!"
    else
      @schedule.start
    end

    respond_to do |format|
      format.js
    end
    #render :layout => false
  end

  def stop
    @schedule.reset
    render :layout => false
  end

  def index
    unless @schedule
      current_user.benchmark_schedule = BenchmarkSchedule.create(:iterations => 1)
      current_user.save!
      get_schedule
    end
    @benchmarks = @schedule.dynamic_profiles || []
    @dynamic_profiles = current_user.dynamic_profiles
    @progress_data = @schedule.progress_data
    @active_schedules = BenchmarkSchedule.where("active = :active AND id <> :id", { :active => true, :id => @schedule.id })
  end

  def remove_profile
    dynamic_profile = DynamicProfile.find(params[:profile])
    @schedule.dynamic_profiles.delete(dynamic_profile)
    @progress_data = @schedule.progress_data
    render 'benchmarks', :layout => false
  end

  def sort
    params[:ids].each_with_index do |profile_id, index|
      dynamic_profile = DynamicProfile.find_by_id(profile_id)
      dynamic_profile.update_attribute(:position, index + 1) if dynamic_profile
    end
    @progress_data = @schedule.progress_data
    render :nothing => true
  end

  def progress
    render :json => @schedule.progress_data.to_json
  end

  private

  def get_schedule
   @schedule = current_user.benchmark_schedule
  end

end
