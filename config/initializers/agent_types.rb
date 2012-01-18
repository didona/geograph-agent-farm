# This initializer calculate the types of agents.

sources = Dir.glob(File.join(Rails.root, 'app', 'models', '*_agent.rb'))
klasses = []
sources.each do |source|
  klass = source.sub(/\.rb$/, '').classify.demodulize
  klasses << klass if klass.constantize < Agent
end
AGENT_TYPES = klasses.sort
AGENT_TYPES_FOR_SELECT = AGENT_TYPES.map{|at| [at.sub(/Agent$/, '').downcase, at]}