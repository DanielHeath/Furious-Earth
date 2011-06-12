PI = 3.141592653589793
GAME_TICK = 25
WALL_BOUNCE = 0.8
DEFAULT_WIDGET_RADIUS = 25
NIMBLE_SHIP_OUTER_RADIUS = 20
SHIP_INNER_RADIUS = 5
BULLET_RADIUS = 3
MAIN_GUN_RELOAD_TIME = 200
BULLET_DAMAGE = 15
pressed = {}

Array::copy = ->
  e for e in @
  
Array::adjust = (other) ->
  for i in [0..(@length - 1)]
    @[i] += other[i]

Array::clampMinTowards = (val) ->
  for i in [0..(@length - 1)]
    if @[i] > val
      @[i] -= 1
      
Array::clampMaxTowards = (val) ->
  for i in [0..(@length - 1)]
    if @[i] < val
      @[i] += 1

Array::increaseBy = (val) ->
  for i in [0..(@length - 1)]
    @[i] *= val
  @

class Widget
  constructor: (@r, @options) ->
    @p ?= @expectedNextPos = @options.position
    @color ?= @options.color
    @vel ?= @options.vel || [0,0]
    @radius ?= options.radius || DEFAULT_WIDGET_RADIUS
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
    
      
class Bullet extends Widget
  constructor: (@r, @options, @firedBy, @firedAt) ->
    @radius = BULLET_RADIUS
    @damage = BULLET_DAMAGE
    super(@r, @options)
    
  draw: (r) ->
    @set = @r.set()
    @set.push @r.circle(@p[0], @p[1], @radius)
    @set.attr({stroke: @color})
    @set.toFront()
  
  destroy: () ->
    @set.remove()
    i = @firedBy.bullets.indexOf(@)
    @firedBy.bullets.splice(i, 1)

  wouldHitTarget: (pos) ->
    @distanceBetween(pos, @firedAt.expectedNextPos) <= (@radius + @firedAt.radius)

  bounceOffShips: () ->
    if @wouldHitTarget(@nextPos())
      @firedAt.takeDamage @damage
      @destroy()

  bounceOffWalls: () ->
    newP = @nextPos()
    @destroy() if ((newP[0] - @radius) < 0) or                   
                ((newP[0] + @radius) > @r.width) or
                ((newP[1] - @radius) < 0) or
                ((newP[1] + @radius) > @r.height)
      
    
class Ship extends Widget
  constructor: (@r, @options) ->
    @accell = @options.accell || [1, 1]
    @bounciness = options.bounciness || 0.8
    @maxHealth = @health = 100
    @mass = options.mass || 2
    @mainGun = {ready: true, reloadTime: MAIN_GUN_RELOAD_TIME}
    @bullets = []
    super
    
  bounceOffShips: () ->
    if @wouldHitOtherShipAt(@nextPos())
      @collideWith(@otherShip)

  takeDamage: (dmg) ->
    @health -= dmg
    @healthIndicator.scale @health / (@maxHealth / @healthIndicator.currentScale)
      
  move: () ->
    super
    bullet.move() for bullet in @bullets

  collisions: () ->
    super
    bullet.collisions() for bullet in @bullets
    
  accellerate: (vector) ->
    @vel.adjust(vector)
    @vel.adjust(vector)
    @vel.clampMaxTowards(8)
    @vel.clampMinTowards(-8)

  collideWith: (otherShip) ->
    osa = @angleTo(otherShip.p)
    mya = @movementAngle()
    da = mya - osa
    @setAngleFromCollision (@angleBetween(@expectedNextPos, otherShip.expectedNextPos) * 2) - @movementAngle()
    @takeDamage(otherShip.mass)
       
  wouldHitOtherShipAt: (pos) ->
    @distanceBetween(pos, @otherShip.expectedNextPos) <= (@radius + @otherShip.radius)
    
  shoot: (type) ->
    if type is 'main'
      if @mainGun.ready and @moving()
        @mainGun.ready = false
        setTimeout((=> @mainGun.ready = true), @mainGun.reloadTime)
        props = {position: @p.copy(), vel: @vel.copy(), color: @color}
        @bullets.push new Bullet(@r, props, @, @otherShip)
        
  bounceOffWalls: () ->
    newP = @nextPos()
    if (newP[0] - @radius) < 0
      @vel[0] = Math.floor(Math.abs(@vel[0]) * WALL_BOUNCE) 
      @takeDamage 1
    if (newP[0] + @radius) > @r.width
      @vel[0] = - Math.floor(Math.abs(@vel[0]) * WALL_BOUNCE) 
      @takeDamage 1
    if (newP[1] - @radius) < 0
      @vel[1] = Math.floor(Math.abs(@vel[1]) * WALL_BOUNCE) 
      @takeDamage 1
    if (newP[1] + @radius) > @r.height
      @vel[1] = - Math.floor(Math.abs(@vel[1]) * WALL_BOUNCE) 
      @takeDamage 1
      
  draw: (r) ->
    @set = @r.set()
    @healthIndicator = @r.circle(@p[0], @p[1], @radius).attr('fill', @color)
    @healthIndicator.currentScale = 1
    inner = @r.circle(@p[0], @p[1], SHIP_INNER_RADIUS)
    inner.attr('fill', 'black')
    @set.push @r.circle(@p[0], @p[1], 5),
      inner,
      @r.circle(@p[0], @p[1], @radius),
      @healthIndicator
    @set.attr({stroke: @color})
    
class Game
  constructor: (@keypresses) ->
    self = this
    @r = Raphael(20, 20, 800, 600)
    @border = @r.rect(2, 2, 798, 598).attr({stroke: "red"})
    @p1 = new Ship(@r, position: [50, 50], radius: NIMBLE_SHIP_OUTER_RADIUS, accell: [2, 2], color: "yellow")
    @p2 = new Ship(@r, position: [500, 500], color: "lightblue")
    
    @status = @r.text( 400, 50, '').attr(fill: "white", 'font-size': '40')
    # TODO: yuk yukkity yuk.
    @p1.otherShip = @p2
    @p2.otherShip = @p1
    
    window.myinterval = setInterval((-> self.tick()), GAME_TICK)

  destroy: ->
    @r.clear()
    $(@r.node).remove()
    
  lose: (ship) ->
    @status.attr(text: "#{ship.color} was destroyed! (space to play again)")
    ship.set.remove()
    clearTimeout(window.myinterval)
    $(window).keypress (e) -> 
      console.log e.keyCode
      if e.keyCode is 32
        window.game.destroy()
        window.game = new Game(pressed)
        $(window).unbind('keypress')

  shooting: {
    p1: {
      81: 'main'
      69: 'secondary'
    }
    p2: {
      191: 'main'
      190: 'secondary'
    }
  }
  movement: {
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
    
    p1Acc.adjust(value) for key, value of @movement.p1 when @keypresses[key]
    p2Acc.adjust(value) for key, value of @movement.p2 when @keypresses[key]
    
    @p1.shoot(value) for key, value of @shooting.p1 when @keypresses[key]
    @p2.shoot(value) for key, value of @shooting.p2 when @keypresses[key]
    
    @p1.accellerate(p1Acc)
    @p2.accellerate(p2Acc)
    @p1.collisions()
    @p2.collisions()
    @p1.move()
    @p2.move()
    
    @status.attr text: "#{@p1.color}: #{@p1.health} - #{@p2.color}: #{@p2.health}"
    @lose(@p1) if @p1.health <= 0
    @lose(@p2) if @p2.health <= 0
    
$ ->
  $(window).keydown (e) ->
    pressed[e.keyCode] = true
  $(window).keyup (e) ->
    delete pressed[e.keyCode]
    
  window.game = new Game(pressed)
