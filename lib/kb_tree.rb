class KdTree
	class << self
		def create(nodelist, depth = 0)
			return nil if nodelist.empty?
			# check
			return Node.new(:location => nodelist.first) if(nodelist.size == 1)

			#puts "nodelist: #{nodelist} - depth: #{depth}"
			# Select axis based on depth so that axis cycles through all valid values
			k = nodelist[0].size
			axis = depth % k

			# Sort point list and choose median as pivot element
			nodelist.sort_by!{|node| node[axis]}
			median = (nodelist.size / 2).floor

			#puts "nodelist: #{nodelist} - axis: #{axis} - median: #{median}"

			# Create node and construct subtrees
			node = Node.new
			node.location = nodelist[median]
			node.left_child = create(nodelist[0..(median -1)], depth + 1)
			node.right_child = create(nodelist[(median + 1)..-1], depth + 1)
			node
		end
	end
end