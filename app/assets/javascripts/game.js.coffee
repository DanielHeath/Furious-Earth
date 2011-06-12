PI = 3.141592653589793
GAME_TICK = 35
WALL_BOUNCE = 0.8
pressed = {}

Array::copy = ->
  e for e in @
  
Array::adjust = (other) ->
  for i in [0..(@length - 1)]
    @[i] += other[i]

Array::clampMax = (val) ->
  for i in [0..(@length - 1)]
    @[i] = Math.min(@[i], val)
    
Array::clampMin = (val) ->
  for i in [0..(@length - 1)]
    @[i] = Math.max(@[i], val)
    
class Ship
  constructor: (@r, @options) ->
    @p = @expectedNextPos = @options.position || [50, 50]
    @vel = @options.vel || [0,0]
    @accell = @options.accell || [1, 1]
    @color = @options.color || "red"
    @radius = options.radius || 45
    @bounciness = options.bounciness || 0.8
    @draw()

  accellerate: (vector) ->
    @vel.adjust(vector)
    @vel.adjust(vector)
    @vel.clampMax(8)
    @vel.clampMin(-8)
    
    
  move: () ->
    @p.adjust(@vel)
    @expectedNextPos = @nextPos()
    @set.translate(@vel[0], @vel[1])

  collisions: () ->
    @bounceOffWalls()
    @bounceOffShips()
    
  bounceOffShips: () ->
    if @wouldHitOtherShipAt(@nextPos())
      @collideWith(@otherShip)

  wouldHitOtherShipAt: (pos) ->
    @distanceBetween(pos, @otherShip.expectedNextPos) <= (@radius + @otherShip.radius)
    
  collideWith: (otherShip) ->
    osa = @angleTo(otherShip.p)
    mya = @movementAngle()
    da = mya - osa
    @setAngleFromCollision (@angleBetween(@expectedNextPos, otherShip.expectedNextPos) * 2) - @movementAngle()
#    throw "Collision didn't bounce me away" if @wouldHitOtherShipAt(@nextPos())
      
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


  bounceOffWalls: () ->
    newP = @nextPos()

    @vel[0] = Math.floor(Math.abs(@vel[0]) * WALL_BOUNCE) if (newP[0] - @radius) < 0
    @vel[0] = - Math.floor(Math.abs(@vel[0]) * WALL_BOUNCE) if (newP[0] + @radius) > @r.width
    @vel[1] = Math.floor(Math.abs(@vel[1]) * WALL_BOUNCE) if (newP[1] - @radius) < 0
    @vel[1] = - Math.floor(Math.abs(@vel[1]) * WALL_BOUNCE) if (newP[1] + @radius) > @r.height
      
  draw: (r) ->
    @set = @r.set()
    @set.push @r.circle(@p[0], @p[1], 5),
      @r.circle(@p[0], @p[1], 25),
      @r.circle(@p[0], @p[1], @radius)
    @set.attr({stroke: @color})
    
class Game
  constructor: (@keypresses) ->
    self = this
    @r = Raphael(20, 20, 800, 600)
    @border = @r.rect(2, 2, 798, 598).attr({stroke: "red"})
    @p1 = new Ship(@r, position: [50, 50], radius: 35, accell: [2, 2], color: "yellow")
    @p2 = new Ship(@r, position: [500, 500], color: "blue")
    
    # TODO: yuk yukkity yuk.
    @p1.otherShip = @p2
    @p2.otherShip = @p1
    
    setInterval((-> self.tick()), GAME_TICK)

  controls: {
    p1: {
      87: [0, -1]
      83: [0,  1]
      65: [-1, 0]
      68: [ 1, 0]
    }
    p2: {
      38: [0, -1]
      40: [0,  1]
      37: [-1, 0]
      39: [ 1, 0]
    }

  }
  tick: () ->
    p1Acc = [0, 0]
    p2Acc = [0, 0]
    
    p1Acc.adjust(value) for key, value of @controls.p1 when @keypresses[key]
    p2Acc.adjust(value) for key, value of @controls.p2 when @keypresses[key]
      
    @p1.accellerate(p1Acc)
    @p2.accellerate(p2Acc)
    @p1.collisions()
    @p2.collisions()
    @p1.move()
    @p2.move()

  draw: ->
    @p1.draw(@r)

$ ->
  $(window).keydown (e) ->
    pressed[e.keyCode] = true
  $(window).keyup (e) ->
    delete pressed[e.keyCode]
    
  window.game = new Game(pressed)
