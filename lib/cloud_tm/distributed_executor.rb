module CloudTm
	class DistributedExecutor
		def initialize
			cache = FenixFramework.getConfig.getBackEnd.getInfinispanCache
			@executor = CloudTm::DefaultExecutorService.new(cache)
		end

		def execute
			task = CloudTm::DistributedTask.new("Distributed Agent Group")
			@executor.submitEverywhere(task)
		end

	end
end