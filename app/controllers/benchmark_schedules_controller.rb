class BenchmarkSchedulesController < ApplicationController

  def update_iterations
    current_user.benchmark_schedule.iterations = params[:iterations]
    current_user.benchmark_schedule.save!
    render :layout => false
  end

  def index
     unless current_user.benchmark_schedule
       current_user.benchmark_schedule = BenchmarkSchedule.create(:iterations => 1)
       current_user.save!
     end
     @experiment = current_user.benchmark_schedule
     @benchmarks =  @experiment.dynamic_profiles || []
     @dynamic_profiles = current_user.dynamic_profiles
   end

end
