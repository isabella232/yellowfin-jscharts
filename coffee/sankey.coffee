define [
	"js/chartingLibraries/d3_3.5.17/d3_3.5.17.min"
], (d3)->

	d3.sankey = ->
		sankey = {}
		nodeWidth = 24
		nodePadding = 8
		size = [
			1
			1
		]
		nodes = []
		links = []
		# Populate the sourceLinks and targetLinks for each node.
		# Also, if the source and target are not objects, assume they are indices.

		computeNodeLinks = ->
			nodes.forEach (node) ->
				node.sourceLinks = []
				node.targetLinks = []
				return
			links.forEach (link) ->
				source = link.source
				target = link.target
				if typeof source == 'number'
					source = link.source = nodes[link.source]
				if typeof target == 'number'
					target = link.target = nodes[link.target]
				source.sourceLinks.push link
				target.targetLinks.push link
				return
			return

		# Compute the value (size) of each node by summing the associated links.

		computeNodeValues = ->
			nodes.forEach (node) ->
				node.value = Math.max(d3.sum(node.sourceLinks, value), d3.sum(node.targetLinks, value))
				return
			return

		# Iteratively assign the breadth (x-position) for each node.
		# Nodes are assigned the maximum breadth of incoming neighbors plus one;
		# nodes with no incoming links are assigned breadth zero, while
		# nodes with no outgoing links are assigned the maximum breadth.

		computeNodeBreadths = ->
			remainingNodes = nodes
			nextNodes = undefined
			x = 0
			while remainingNodes.length
				nextNodes = []
				remainingNodes.forEach (node) ->
					node.x = x
					node.dx = nodeWidth
					node.sourceLinks.forEach (link) ->
						nextNodes.push link.target
						return
					return
				remainingNodes = nextNodes
				++x
			#
			moveSinksRight x
			scaleNodeBreadths (size[0] - nodeWidth) / (x - 1)
			return

		moveSourcesRight = ->
			nodes.forEach (node) ->
				if !node.targetLinks.length
					node.x = d3.min(node.sourceLinks, (d) ->
						d.target.x
					) - 1
				return
			return

		moveSinksRight = (x) ->
			nodes.forEach (node) ->
				if !node.sourceLinks.length
					node.x = x - 1
				return
			return

		scaleNodeBreadths = (kx) ->
			nodes.forEach (node) ->
				node.x *= kx
				return
			return

		computeNodeDepths = (iterations) ->
			nodesByBreadth = d3.nest().key((d) ->
				d.x
			).sortKeys(d3.ascending).entries(nodes).map((d) ->
				d.values
			)
			#

			initializeNodeDepth = ->
				ky = d3.min(nodesByBreadth, (nodes) ->
					(size[1] - ((nodes.length - 1) * nodePadding)) / d3.sum(nodes, value)
				)
				nodesByBreadth.forEach (nodes) ->
					nodes.forEach (node, i) ->
						node.y = i
						node.dy = node.value * ky
						return
					return
				links.forEach (link) ->
					link.dy = link.value * ky
					return
				return

			relaxLeftToRight = (alpha) ->

				weightedSource = (link) ->
					center(link.source) * link.value

				nodesByBreadth.forEach (nodes, breadth) ->
					nodes.forEach (node) ->
						if node.targetLinks.length
							y = d3.sum(node.targetLinks, weightedSource) / d3.sum(node.targetLinks, value)
							node.y += (y - center(node)) * alpha
						return
					return
				return

			relaxRightToLeft = (alpha) ->

				weightedTarget = (link) ->
					center(link.target) * link.value

				nodesByBreadth.slice().reverse().forEach (nodes) ->
					nodes.forEach (node) ->
						if node.sourceLinks.length
							y = d3.sum(node.sourceLinks, weightedTarget) / d3.sum(node.sourceLinks, value)
							node.y += (y - center(node)) * alpha
						return
					return
				return

			resolveCollisions = ->
				nodesByBreadth.forEach (nodes) ->
					node = undefined
					dy = undefined
					y0 = 0
					n = nodes.length
					i = undefined
					# Push any overlapping nodes down.
					nodes.sort ascendingDepth
					i = 0
					while i < n
						node = nodes[i]
						dy = y0 - (node.y)
						if dy > 0
							node.y += dy
						y0 = node.y + node.dy + nodePadding
						++i
					# If the bottommost node goes outside the bounds, push it back up.
					dy = y0 - nodePadding - (size[1])
					if dy > 0
						y0 = node.y -= dy
						# Push any overlapping nodes back up.
						i = n - 2
						while i >= 0
							node = nodes[i]
							dy = node.y + node.dy + nodePadding - y0
							if dy > 0
								node.y -= dy
							y0 = node.y
							--i
					return
				return

			ascendingDepth = (a, b) ->
				a.y - (b.y)

			initializeNodeDepth()
			resolveCollisions()
			alpha = 1
			while iterations > 0
				relaxRightToLeft alpha *= .99
				resolveCollisions()
				relaxLeftToRight alpha
				resolveCollisions()
				--iterations
			return

		computeLinkDepths = ->

			ascendingSourceDepth = (a, b) ->
				a.source.y - (b.source.y)

			ascendingTargetDepth = (a, b) ->
				a.target.y - (b.target.y)

			nodes.forEach (node) ->
				node.sourceLinks.sort ascendingTargetDepth
				node.targetLinks.sort ascendingSourceDepth
				return
			nodes.forEach (node) ->
				sy = 0
				ty = 0
				node.sourceLinks.forEach (link) ->
					link.sy = sy
					sy += link.dy
					return
				node.targetLinks.forEach (link) ->
					link.ty = ty
					ty += link.dy
					return
				return
			return

		center = (node) ->
			node.y + node.dy / 2

		value = (link) ->
			link.value

		sankey.nodeWidth = (_) ->
			if !arguments.length
				return nodeWidth
			nodeWidth = +_
			sankey

		sankey.nodePadding = (_) ->
			if !arguments.length
				return nodePadding
			nodePadding = +_
			sankey

		sankey.nodes = (_) ->
			if !arguments.length
				return nodes
			nodes = _
			sankey

		sankey.links = (_) ->
			if !arguments.length
				return links
			links = _
			sankey

		sankey.size = (_) ->
			if !arguments.length
				return size
			size = _
			sankey

		sankey.layout = (iterations) ->
			computeNodeLinks()
			computeNodeValues()
			computeNodeBreadths()
			computeNodeDepths iterations
			computeLinkDepths()
			sankey

		sankey.relayout = ->
			computeLinkDepths()
			sankey

		sankey.link = ->
			curvature = .5

			link = (d) ->
				x0 = d.source.x + d.source.dx
				x1 = d.target.x
				xi = d3.interpolateNumber(x0, x1)
				x2 = xi(curvature)
				x3 = xi(1 - curvature)
				y0 = d.source.y + d.sy + d.dy / 2
				y1 = d.target.y + d.ty + d.dy / 2
				'M' + x0 + ',' + y0 + 'C' + x2 + ',' + y0 + ' ' + x3 + ',' + y1 + ' ' + x1 + ',' + y1

			link.curvature = (_) ->
				if !arguments.length
					return curvature
				curvature = +_
				link

			link

		sankey
