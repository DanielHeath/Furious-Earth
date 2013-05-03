window.furiousEarth.Ship = class Ship extends window.furiousEarth.Widget
  constructor: (@r, @options) ->
    @accell = (@options.accell || 1) / window.furiousEarth.SCALE
    @accell *= window.furiousEarth.SPEED
    @bounciness = options.bounciness || 0.8
    @maxHealth = @health = 200
    @mass = options.mass || 2
    @mainGun = {ready: true, reloadTime: window.furiousEarth.MAIN_GUN_RELOAD_TIME * window.furiousEarth.SPEED}
    @bullets = []
    @name = @options.name || @options.color
    @topSpeed = ((@options.topSpeed || 8) / window.furiousEarth.SCALE) * window.furiousEarth.SPEED
    @shotProfile = @options.shotProfile || [10, 20, 25, 30, 35, 50, 80, 130, 210, 400]
    super

  bounceOffShips: () ->
    if @wouldHitOtherShipAt(@nextPos())
      @collideWith(@otherShip)

  takeDamage: (dmg, msg) ->
    @health -= dmg
    @damageMsg = msg
    @healthIndicator.scale @health / (@maxHealth / @healthIndicator.currentScale)

  move: () ->
    super
    bullet.move() for bullet in @bullets

  collisions: () ->
    super
    bullet?.collisions() for bullet in @bullets

  accellerate: (vector) ->
    @vel.adjust(vector.increaseBy(@accell))
    @vel.clampMaxTowards(@topSpeed)
    @vel.clampMinTowards(0 - @topSpeed)

  collideWith: (otherShip) ->
    window.game.flash()

    osa = @angleTo(otherShip.p)
    mya = @movementAngle()
    da = mya - osa
    @setAngleFromCollision (@angleBetween(@expectedNextPos, otherShip.expectedNextPos) * 2) - @movementAngle()
    @takeDamage(otherShip.mass, "when #{otherShip.name} smashed through them")

  wouldHitOtherShipAt: (pos) ->
    @distanceBetween(pos, @otherShip.expectedNextPos) <= (@radius + @otherShip.radius)

  shoot: (type) ->
    if type is 'main'
      if @mainGun.ready
        @mainGun.ready = false
        setTimeout((=> @mainGun.ready = true), @mainGun.reloadTime)
        for time in @shotProfile
          setTimeout((=>
            props = {position: @p.copy(), vel: @vel.copy().jiggle(), color: @color}
            @bullets.push new window.furiousEarth.Bullet(@r, props, @, @otherShip)
          ), time)

  bounceOffWalls: () ->
    newP = @nextPos()
    if (newP[0] - @radius) < 0
      @vel[0] = Math.floor(Math.abs(@vel[0]) * window.furiousEarth.WALL_BOUNCE)
      @takeDamage 1, "because they couldn't drive"
    if (newP[0] + @radius) > @r.width
      @vel[0] = - Math.floor(Math.abs(@vel[0]) * window.furiousEarth.WALL_BOUNCE)
      @takeDamage 1, "when an immobile wall surprised them"
    if (newP[1] - @radius) < 0
      @vel[1] = Math.floor(Math.abs(@vel[1]) * window.furiousEarth.WALL_BOUNCE)
      @takeDamage 1, "faceplanted (again)"
    if (newP[1] + @radius) > @r.height
      @vel[1] = - Math.floor(Math.abs(@vel[1]) * window.furiousEarth.WALL_BOUNCE)
      @takeDamage 1, "needs a portal gun"

  draw: (r) ->
    @set = @r.set()
    @healthIndicator = @r.circle(@p[0], @p[1], @radius).attr('fill', @color)
    @healthIndicator.currentScale = 1
    inner = @r.circle(@p[0], @p[1], window.furiousEarth.SHIP_INNER_RADIUS)
    inner.attr('fill', 'black')
    @set.push @r.circle(@p[0], @p[1], 5),
      inner,
      @r.circle(@p[0], @p[1], @radius),
      @healthIndicator
    @set.attr({stroke: @color})

