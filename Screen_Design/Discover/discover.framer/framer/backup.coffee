# This imports all the layers for "Discover" into discoverLayers1
importLayers = Framer.Importer.load "imported/Discover"

superContainer = new Layer
	backgroundColor: "transparent", height: 1334, width: 750, borderRadius: 0

container = new Layer 
 	backgroundColor: "transparent", height:1334, width: 2000, borderRadius:4
 	
container.superLayer = superContainer
container.draggable.enabled = true
container.draggable.speedY = 0
container.x = 0
container.y = 0

scrolling = false

details = new Layer y: 0, opacity: 0, width: 750, height: 483, image: "images/details.png"
interstellar = new Layer x:120, width:511, height:797, image:"images/Interstellar.png"
frozen = new Layer x:700, width:511, height:797, image:"images/Frozen.png"
transformers = new Layer x:1280, width:511, height:797, image:"images/Transformers.png"

interstellar.superLayer = container
frozen.superLayer = container
transformers.superLayer = container

container.on Events.DragStart, ->
	scrolling = true
	print scrolling
container.on Events.DragEnd, ->
	scrolling = false
	print scrolling
	velocity = container.draggable.calculateVelocity()
	this.animate
 		properties: {x: scrollOffsetForStop(this.x, velocity)}
 		curve:	"spring(400,25,0)"
container.on Events.DragMove, ->
 	if this.x > 0
 		this.draggable.speedX = .5
 	else if this.x < (movies[movies.length - 1].x - 120) * -1
 		this.draggable.speedX = .5
 	else
 		this.draggable.speedX = 1

scrollOffsetForStop = (stopX, velocity) ->
	center = stopX * -1 + 750/2
	closestCenterX = 0
	closestCenterOffset = 10000000
	index = -1
	i = 0
	for movie in movies
		absCenter = abs(center - movieCenterX(movie))
		if absCenter < closestCenterOffset
			closestCenterOffset = absCenter
			closestCenterX = movieCenterX(movie)
			index = i
		i++
	if (abs(velocity.x) > 1.5)
		if velocity.x < 0 && center - movieCenterX(movie) < 0 && index < movies.length - 1
			return -movieCenterX(movies[index+1]) + movies[0].width/2 + movies[0].x
		if velocity.x > 0 && center - movieCenterX(movie) < 0 && index > 0
			return -movieCenterX(movies[index-1]) + movies[0].width/2 + movies[0].x
	return -closestCenterX + movies[0].width/2 + movies[0].x

details.center()
details.y = interstellar.y + interstellar.height
details.originY = 0
details.originX = .5
details.scaleX = .6
details.scaleY = 0

details.states.add
	up: {opacity: 1, scaleY: 1, scaleX: 1}
	
details.states.animationOptions =
	curve: "spring(500,20,0)"

movieCenterX = (movie) ->
	return movie.x + movie.width/2

movies = [interstellar, frozen, transformers]

originalMovieY = 171

for movie in movies
	movie.y = originalMovieY
	movie.superLayer = container
	movie.states.add
		second: {y: 0}
	movie.states.animationOptions =
		curve: "spring(500,20,0)"
	movie.draggable.enabled = true
	movie.draggable.speedX = 0
	movie.draggable.speedY = 1
	
	movie.on Events.DragMove, ->
		percentage = (originalMovieY - this.y)/originalMovieY
		if percentage > 0 && !scrolling
# 			this.scale = 1 + percentage * .5
			details.opacity = percentage
			details.scaleY = percentage
			details.scaleX = .6 + .4 * percentage
		else
			this.y = originalMovieY
	movie.on Events.DragEnd, ->
		if !scrolling
			details.states.next()
			this.states.next()
				
abs = (input) ->
	if input > 0
		return input
	else
		return input * -1