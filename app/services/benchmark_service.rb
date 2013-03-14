class BenchmarkService
  include Madmass::Transaction::TxMonitor

  def initialize(opts={})
    @sleep = opts['sleep']
    # right value is 60, reduce it only if you want test rapidly
    @cycle_seconds = 10
  end

  def start
    Thread.new { run }
  end

  def stop
    @done = true
  end

  def distribute_task
    begin
      log(:debug) { "Starting the Distributed Executor ..." }
      executor = CloudTm::DistributedExecutor.new
      executor.execute
      log(:debug) { "Distributed Executor started ..." }
      
    rescue Exception => ex
      log(:debug) { "Exception running distributed executor: #{ex.message}" } 
    end

    tx_monitor do
      log(:debug) { "Searching Agent Groups ..." }
      CloudTm::AgentGroup.all.each do |agent_group|
        log(:debug) { "Found Agent Group: #{agent_group.inspect}" }
      end
    end
  end

  def run
    # temp
    distribute_task

    @current_benchmark = nil
    @step_start_time = nil
    @current_dynamic_profile = nil

    begin
      tx_monitor do
        CloudTm::Route.load_routes #Preload routes
      end
    rescue Exception => ex
      log(:error) {ex.message}
    end

    until @done
      
      log(:debug) { "start new cycle ..." }

      sleep(@sleep)

      benchmark = active_benchmark

      # there is no benchmark
      unless benchmark
        log(:debug) { "no active benchmark" }
        initialize_benchmark        
        log(:debug) { "cycle finished without benchmarks" }
        next
      end

      # stopping previous benchmark
      if @current_benchmark != benchmark
        @current_static_profile.stop if @current_static_profile
        log(:debug) { "executing previous benchmark, stopping it ..." }
      end

      # switching to new benchmark
      if(@current_benchmark == nil || (@current_benchmark != benchmark))
        log(:debug) { "setting new benchmark ..." }
        switch_to_new_benchmark(benchmark)
        log(:debug) { "cycle finished with new profile start" }
        next
      end

      profile_progress = ((Time.now - @step_start_time) / (@current_static_profile.duration * @cycle_seconds)) * 100
      @current_benchmark.update_attributes(:static_profile_id => @current_static_profile.id, :static_profile_progress => profile_progress)

      # execution of current step
      # checks if the step is finished
      if( (@current_static_profile.duration * @cycle_seconds) <= (Time.now - @step_start_time) )
        log(:debug) { "step #{@current_static_profile.id} completed" }
        
        begin
          @current_static_profile.stop
        rescue Exception => ex
          log(:error) {ex.message}
        end

        @step_start_time = Time.now
        next_step

        # it was the last step
        unless @current_static_profile
          # check iterations
          log(:debug) { 'benchmark completed!' }
          @current_benchmark = nil
          @step_start_time = nil
          next
        end

        # start the new step
        begin
          @current_static_profile.start
        rescue Exception => ex
          log(:error) {ex.message}
        end

        log(:debug) { 'new step started ...' }
      end

      log(:debug) { 
        @current_benchmark.reload
        progress_data = @current_benchmark.progress_data
        global_progress = progress_data[:global_progress]
        profile_progress = @current_benchmark.static_profile_progress
        dynamic_progress = progress_data[:dynamic_profiles][@current_dynamic_profile.id][:progress]
        "cycle finished \n" +
        "[benchmark] id: #{@current_benchmark.id} - progress: #{global_progress}% - iterations: #{@current_benchmark.current_iteration} \n" +
        "[dynamic  ] id: #{@current_dynamic_profile.id} - progress: #{dynamic_progress}% - iterations: #{@current_dynamic_profile.current_iteration} \n" +
        "[static   ] id: #{@current_static_profile.id} - progress: #{profile_progress}% " 
      }
    end
  end

  private

  def initialize_benchmark
    @current_static_profile.stop if @current_static_profile
    @current_benchmark = nil
    @step_start_time = nil
    @current_static_profile = nil
    @current_dynamic_profile = nil
  end

  def switch_to_new_benchmark(benchmark)
    @current_benchmark = benchmark
    @step_start_time = Time.now
    @current_benchmark.update_attributes(:start_time => @step_start_time)
    @current_dynamic_profile = @current_benchmark.dynamic_profiles.first
    @current_dynamic_profile.update_attribute(:current_iteration, 1)
    @current_static_profile = @current_dynamic_profile.static_profiles.first

    begin
      @current_static_profile.start
      log(:debug) { "new profile started ..." }
    rescue Exception => ex
      log(:error) {ex.message}
    end
  end

  def next_step
    # get the next profile
    previous_index = @current_dynamic_profile.static_profiles.index(@current_static_profile)
    
    if(@current_dynamic_profile.static_profiles.size == previous_index + 1)
      # check the current profile iteration
      current_profile_iteration = @current_dynamic_profile.current_iteration || 1
      profile_iterations = @current_dynamic_profile.iterations || 1
      if(current_profile_iteration < profile_iterations)
        # go to the next profile iteration
        @current_static_profile = @current_dynamic_profile.static_profiles.first
        @current_benchmark.update_attributes(:static_profile_progress => 0)
        @current_dynamic_profile.update_attribute(:current_iteration, current_profile_iteration + 1)
        log(:debug) { 'go to the next profile iteration' }
      else
        # reset the profile iteration counter
        @current_dynamic_profile.update_attribute(:current_iteration, 1)

        # go to next dynamic profile
        previous_dynamic_index = @current_benchmark.dynamic_profiles.index(@current_dynamic_profile)
        if(@current_benchmark.dynamic_profiles.size == previous_dynamic_index + 1)
          # check if benchmark is completed
          unless @current_benchmark.last_iteration?
            next_iteration = @current_benchmark.current_iteration ? @current_benchmark.current_iteration + 1 : 2
            @current_benchmark.update_attributes(:current_iteration => next_iteration, :static_profile_progress => 0, :static_profile_id => nil)
            log(:debug) { "go to next iteration #{@current_benchmark.current_iteration} ..." }
          else
            # benchmark completed!
            @current_benchmark.reset
            log(:debug) { 'benchmark completed (in next_step)!' }
          end
          @current_static_profile = nil
          @current_dynamic_profile = nil
          @current_benchmark = nil

          next
        else
          # go to next dynamic profile
          @current_dynamic_profile = @current_benchmark.dynamic_profiles[previous_dynamic_index + 1]
          @current_dynamic_profile.update_attribute(:current_iteration, 1)
          @current_static_profile = @current_dynamic_profile.static_profiles.first
        end

      end
    else
      # go to next static profile
      @current_static_profile = @current_dynamic_profile.static_profiles[previous_index + 1]
    end
    @current_benchmark.update_attributes(:static_profile_progress => 0, :static_profile_id => @current_static_profile.id)
  end

  def active_benchmark
    benchmarks = BenchmarkSchedule.where(:active => true)
    if(benchmarks.count > 1)
      log(:error) { 'multiple benchmarks are active!' }
      benchmarks.each do |b|
        log(:error) { b.inspect }
      end
    end

    benchmarks.first
  end

  def log(level, &block)
    if Rails.env == 'development'
      text = yield
      Rails.logger.send(level, "[BenchmarkService] <#{Time.now.strftime('%d-%m-%Y %H:%M:%S')}> : #{text}")
    end
  end

end

