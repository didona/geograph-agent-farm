class Node
	attr_accessor :location, :left_child, :right_child

	def initialize(attributes = {})
		@location = attributes[:location]
		@left_child = attributes[:left_child]
		@right_child = attributes[:right_child]
	end

	def print
		print_string = "location: #{@location.inspect}"
		print_string += " => left: #{@left_child.print}" if @left_child
		print_string += " => right: #{@right_child.print}" if @right_child
		puts print_string
	end
end