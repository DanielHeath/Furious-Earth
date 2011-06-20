window.furiousEarth.Widget = class Widget
  constructor: (@r, @options) ->
    @p ?= @expectedNextPos = @options.position
    @color ?= @options.color
    @vel ?= @options.vel || [0,0]
    @radius ?= options.radius || window.furiousEarth.DEFAULT_WIDGET_RADIUS
    @draw()
    
  move: () ->
    @p.adjust(@vel)
    @expectedNextPos = @nextPos()
    @set.translate(@vel[0], @vel[1])

  collisions: () ->
    @bounceOffWalls()
    @bounceOffShips()
    
  setAngleFromCollision: (angle) ->
    @vel = @velocityAtAngle(angle)
    
  distanceBetween: (p1, p2) ->
    dx = Math.abs(p1[0] - p2[0])
    dy = Math.abs(p1[1] - p2[1])
    Math.floor(Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2)))
  
  distanceTo: (point) ->
    @distanceBetween(@p, point)
    
  movementAngle: () ->
    @angleTo @nextPos()

  speed: () ->
    Math.sqrt Math.pow(@vel[0], 2) + Math.pow(@vel[1], 2)
    
  velocityAtAngle: (angle) ->
    [Math.floor(@speed() * Math.sin(angle)), Math.floor(@speed() * Math.cos(angle))]
    
  angleBetween: (p1, p2) ->
    Raphael.angle(p1[0], p1[1], p2[0], p2[1])
    
  angleTo: (point) ->
    @angleBetween(@p, point)
    
  nextPos: () ->
    @p.copy().adjust(@vel)

  moving: () ->
    @vel[0] or @vel[1]
    
