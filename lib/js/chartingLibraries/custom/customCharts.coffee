define [
	"js/chartingLibraries/d3_3.5.17/d3_3.5.17.min"
	"js/chartingLibraries/custom/sankey"
], (d3, sankey)->

	return customCharts =


		tableSparklines: (width, data, columns, tableId) ->
			# create table head
			table = document.getElementById(tableId)
			table.style.width= + width + 'px';
			thead = document.createElement('thead')
			tr = document.createElement('tr')

			for col in columns
				th = document.createElement('th')
				th.id = 'col-' + col + "-head"
				if col.indexOf('sparkline') > -1
					th.className = 'td-sparkline'
				th.innerHTML = col
				tr.append(th)

			thead.append(tr)
			table.append(thead)

			# create table body
			tbody = document.createElement('tbody')
			table.append(tbody)

			for row in [0...data[columns[0]].length]
				tr = document.createElement('tr')
				tbody.append(tr)

				for col in columns
					td = document.createElement('td')
					td.id = 'col-' + col + "-" + row

					if col.indexOf('sparkline') > -1
						td.className = 'td-sparkline'
						tr.append(td);
						this.sparkline(data[col][row].formatted_data, "#col-" + col + "-" + row)
					else
						td.innerHTML = data[col][row].formatted_data
						tr.append(td)


		# from: http://www.tnoda.com/blog/2013-12-19

		sparkline: (data, element) ->
			el = d3.select(element)

			width = el[0][0].offsetWidth
			height = el[0][0].offsetHeight

			x = d3.scale.linear().range([
				0
				width
			])
			y = d3.scale.linear().range([
				height
				0
			])
			line = d3.svg.line().x((d) ->
				x d.x
			).y((d) ->
				y d.y
			)

			draw = (data, element) ->
				x.domain d3.extent(data, (d) ->
					d.x = +d.x
				)
				y.domain d3.extent(data, (d) ->
					d.y = +d.y
				)
				svg = d3.select(element).append('svg').attr('width', width).attr('height', height).append('path').datum(data).attr('class', 'sparkline').attr('d', line)
				point = svg.append('g').attr('class', 'sparkline-point')
				point.selectAll('circle').data((d) ->
					d
				).enter().append('circle').attr('cx', (d) ->
					x d.x
				).attr('cy', (d) ->
					y d.y
				).attr('r', 3.5).style('fill', 'white').style('stroke', 'black')
				return

			draw(data, element)


		# from p&p

		topProduct: (name, image, link, data) ->
			# Name
			headding = document.createElement('h1')

			kFormatter = (num) ->
				if num > 999 then (num / 1000).toFixed(1) + 'K' else num

			infoFormatter = (infos) ->
				list = ''
				for key of infos
					`key = key`
					if !isNaN(infos[key])
						list += '<li><h2>' + kFormatter(infos[key]) + '</h2><p>' + key.replaceAll('_', ' ') + '</p></li>'
				list

			headding.id = 'product-name'
			headding.innerHTML = name

			# Image
			img = document.createElement('img')
			img.src = image
			a = document.createElement('a')
			a.href = link
			a.target = '_blank'
			a.append img

			# Info
			list = document.createElement('ul')
			list.innerHTML = infoFormatter(data)

			# Containers
			cImg = document.createElement('div')
			cImg.id = 'product-image'
			cImg.className = 'left'
			cImg.append headding
			cImg.append a
			cInfo = document.createElement('div')
			cInfo.id = 'product-stats'
			cInfo.className = 'left'
			cInfo.append list
			cProduct = document.createElement('div')
			cProduct.id = 'product'
			cProduct.className = 'left'
			cProduct.append cImg
			cProduct.append cInfo
			c = document.createElement('div')
			c.id = 'container'
			c.className = 'left'
			c.append cProduct
			c



		# from: https://codepen.io/jaketrent/pen/eloGk

		gauge: (data, element) ->
			Needle = undefined
			arc = undefined
			arcEndRad = undefined
			arcStartRad = undefined
			barWidth = undefined
			chart = undefined
			chartInset = undefined
			degToRad = undefined
			el = undefined
			endPadRad = undefined
			height = undefined
			i = undefined
			margin = undefined
			needle = undefined
			numSections = undefined
			padRad = undefined
			percToDeg = undefined
			percToRad = undefined
			percent = undefined
			radius = undefined
			ref = undefined
			sectionIndx = undefined
			sectionPerc = undefined
			startPadRad = undefined
			svg = undefined
			totalPercent = undefined
			width = undefined

			percent = data
			barWidth = 20
			numSections = 5
			sectionPerc = 1 / numSections / 2
			padRad = 0
			chartInset = 10
			totalPercent = .75
			el = d3.select(element)
			margin =
				top: 20
				right: 20
				bottom: 30
				left: 20
			width = el[0][0].offsetWidth - (margin.left) - (margin.right)
			height = width
			radius = Math.min(width, height) / 2

			percToDeg = (perc) ->
				perc * 360

			percToRad = (perc) ->
				degToRad percToDeg(perc)

			degToRad = (deg) ->
				deg * Math.PI / 180

			svg = el.append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom)
			chart = svg.append('g').attr('transform', 'translate(' + (width + margin.left) / 2 + ', ' + (height + margin.top) / 2 + ')')

			Needle = do ->
				`var Needle`

				Needle = (len, cl) ->
					@len = len
					@cl = cl
					return

				Needle::drawOn = (el, perc) ->
					el.append('path').attr('class', @cl).attr 'd', @mkCmd(perc)

				Needle::animateOn = (el, perc) ->
					self = undefined
					self = this
					el.transition().delay(500).ease('elastic').duration(3000).selectAll('.' + @cl).tween 'progress', ->
						(percentOfPercent) ->
							progress = undefined
							progress = percentOfPercent * perc
							d3.select(this).attr 'd', self.mkCmd(progress)

				Needle::mkCmd = (perc) ->
					thetaRad = undefined
					thetaRad = percToRad(perc / 2)
					centerX = 0
					centerY = 0
					startX = centerX - ((@len + 30) * Math.cos(thetaRad))
					startY = centerY - ((@len + 30) * Math.sin(thetaRad))
					endX = centerX - ((@len - 10) * Math.cos(thetaRad))
					endY = centerY - ((@len - 10) * Math.sin(thetaRad))
					'M ' + startX + ' ' + startY + ' L ' + endX + ' ' + endY

				Needle

			needle = new Needle(100, "needle")
			needle.drawOn chart, 0
			needle.animateOn chart, percent

			sectionIndx = i = 1
			ref = numSections
			while (if 1 <= ref then i <= ref else i >= ref)
				arcStartRad = percToRad(totalPercent)
				arcEndRad = arcStartRad + percToRad(sectionPerc)
				totalPercent += sectionPerc
				startPadRad = if sectionIndx == 0 then 0 else padRad / 2
				endPadRad = if sectionIndx == numSections then 0 else padRad / 2
				arc = d3.svg.arc().outerRadius(radius - chartInset).innerRadius(radius - chartInset - barWidth).startAngle(arcStartRad + startPadRad).endAngle(arcEndRad - endPadRad)
				chart.append('path').attr('class', 'arc chart-color' + sectionIndx).attr 'd', arc
				sectionIndx = if 1 <= ref then ++i else --i

			return



		# from: http://bl.ocks.org/d3noob/5028304, https://github.com/d3/d3-sankey

		sankey: (data, dimensions, metric, element) ->
			units = metric

			# formatting data nodes and links

			formatData = (raw, dimensions, metric) ->
				formatted = {}
				formatted.links = []
				formatted.nodes = []
				drills = {}
				flags = []
				i = 0
				while i < raw[dimensions[0]].length
					for j of dimensions
						# create distinct nodes
						j = parseInt(j)
						dimension = dimensions[j]
						if flags.indexOf(raw[dimension][i].raw_data.toString()) == -1
							flags.push raw[dimension][i].raw_data.toString()
							formatted.nodes.push name: raw[dimension][i].raw_data.toString()
						if j < dimensions.length - 1
							# create dimensionconnections and sum
							d = raw[dimensions[j]][i].raw_data + ':' + raw[dimensions[j + 1]][i].raw_data
							if flags.indexOf(d) == -1
								flags.push d
								drills[d] =
									source: raw[dimensions[j]][i].raw_data
									target: raw[dimensions[j + 1]][i].raw_data
									value: raw[metric][i].raw_data
							else
								drills[d].value += raw[metric][i].raw_data
					i++
				for k of drills
					`k = k`
					formatted.links.push drills[k]

				formatted

			# the function for moving the nodes

			dragmove = (d) ->
				d3.select(this).attr 'transform', 'translate(' + (d.x = Math.max(0, Math.min(width - (d.dx), d3.event.x))) + ',' + (d.y = Math.max(0, Math.min(height - (d.dy), d3.event.y))) + ')'
				sankey.relayout()
				link.attr 'd', path
				return

			el = d3.select(element)
			margin =
				top: 10
				right: 10
				bottom: 10
				left: 10
			width = el[0][0].offsetWidth - (margin.left) - (margin.right)
			height = el[0][0].offsetHeight - (margin.top) - (margin.bottom)
			formatNumber = d3.format(',.0f')

			format = (d) ->
				formatNumber(d) + ' ' + units

			# color = d3.scale.category20c()
			color = d3.scale.ordinal().range(["#9CDBFB", "#47CCFA", "#329DE5", "#C3C3DA", "#8488B2", "#072269", "#3C53B9", "#333333", "#AAAAAA", "#E5E5E5"])
			# append the svg canvas to the page
			svg = d3.select(element).append('svg').attr('width', width + margin.left + margin.right).attr('height', height + margin.top + margin.bottom).append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
			# Set the sankey diagram properties
			sankey = d3.sankey().nodeWidth(8).nodePadding(5).size([
				width
				height
			])
			path = sankey.link()
			# load the data
			graph = formatData(data, dimensions, metric)
			nodeMap = {}
			graph.nodes.forEach (x) ->
				nodeMap[x.name] = x
				return
			graph.links = graph.links.map((x) ->
				{
					source: nodeMap[x.source]
					target: nodeMap[x.target]
					value: x.value
				}
			)
			sankey.nodes(graph.nodes).links(graph.links).layout 32
			# add in the links
			link = svg.append('g').selectAll('.link').data(graph.links).enter().append('path').attr('class', 'link').attr('d', path).style('stroke-width', (d) ->
				Math.max 1, d.dy
			).sort((a, b) ->
				b.dy - (a.dy)
			)
			# add the link titles
			link.append('title').text (d) ->
				d.source.name + ' → ' + d.target.name + '\n' + format(d.value)
			# add in the nodes
			node = svg.append('g').selectAll('.node').data(graph.nodes).enter().append('g').attr('class', 'node').attr('transform', (d) ->
				'translate(' + d.x + ',' + d.y + ')'
			).call(d3.behavior.drag().origin((d) ->
				d
			).on('dragstart', ->
				@parentNode.appendChild this
				return
			).on('drag', dragmove))
			# add the rectangles for the nodes
			node.append('rect').attr('height', (d) ->
				d.dy
			).attr('width', sankey.nodeWidth()).style('fill', (d) ->
				d.color = color(d.name.replace(RegExp(' .*'), ''))
			).append('title').text (d) ->
				d.name + '\n' + format(d.value)
			# add in the title for the nodes
			node.append('text').attr('x', -6).attr('y', (d) ->
				d.dy / 2
			).attr('dy', '.35em').attr('text-anchor', 'end').attr('transform', null).text((d) ->
				d.name
			).filter((d) ->
				d.x < width / 2
			).attr('x', 6 + sankey.nodeWidth()).attr 'text-anchor', 'start'


