class BenchmarkService

  def initialize(opts={})
    @sleep = opts['sleep']
  end

  def start
    Thread.new { run }
  end

  def stop
    @done = true
  end

  def run

    @current_benchmark = nil
    @step_start_time = nil
    @current_position = 0

    until @done

      Rails.logger.debug "== BENCHMARK SERVICE =="

      sleep(@sleep)

      benchmark = active_benchmark

      #there is no benchmark
      unless benchmark
        Rails.logger.debug "No active benchmark"
        sleep(@sleep)
        Rails.logger.debug "=================="
        next
      end

      #Switching to new benchmark
      if (@current_benchmark == nil || (@current_benchmark != benchmark))
        Rails.logger.debug "setting new benchmark"
        @current_benchmark = benchmark
        @step_start_time = Time.now
        @current_position += 1

        @current_profile = @current_benchmark.dynamic_profiles.first.static_profiles.where(:position => @current_position).first
        Rails.logger.debug "Starting profile at position #{@current_position}"
        @current_profile.start
        Rails.logger.debug "=================="
        next
      end

      #Execution of current step
      @current_profile = @current_benchmark.dynamic_profiles.first.static_profiles.where(:position => @current_position).first

      #Checks if the step is finished
      if (@current_profile.duration*60 <= (Time.now-@step_start_time))
        Rails.logger.debug "Step #{@current_position} completed"
        @current_profile.stop
        sleep(2*@sleep) #FIXME: put max among delays @current_profile.max_delay
        @step_start_time = Time.now
        @current_position += 1
        @current_profile = @current_benchmark.dynamic_profiles.first.static_profiles.where(:position => @current_position).first
        #It was the last step
        unless @current_profile
          Rails.logger.debug "Benchmark completed"
          @current_benchmark = nil
          @step_start_time = nil
          @current_position = 0
          next
        end
        #Start the new step
        Rails.logger.debug "New Step started"
        @current_profile.start
      end
      Rails.logger.debug "=================="
    end
  end

  private

  def active_benchmark
    benchmarks = BenchmarkSchedule.where(:active => true)
    if (benchmarks.length > 1)
      Rails.logger.error("Multiple benchmarks are active!")
      benchmarks.each do |b|
        Rails.logger.error("#{b.inspect}")
      end
    end

    benchmarks.first
  end

end

