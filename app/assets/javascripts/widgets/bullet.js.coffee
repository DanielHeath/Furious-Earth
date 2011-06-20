window.furiousEarth.Bullet = class Bullet extends window.furiousEarth.Widget
  constructor: (@r, @options, @firedBy, @firedAt) ->
    @radius = window.furiousEarth.BULLET_RADIUS
    @damage = window.furiousEarth.BULLET_DAMAGE
    super(@r, @options)
    
  draw: (r) ->
    @set = @r.set()
    @set.push @r.circle(@p[0], @p[1], @radius)
    @set.attr({stroke: @color, fill: @color})
    @set.toFront()
  
  destroy: () ->
    @set.remove()
    i = @firedBy.bullets.indexOf(@)
    @firedBy.bullets.splice(i, 1)

  wouldHitTarget: (pos) ->
    @distanceBetween(pos, @firedAt.expectedNextPos) <= (@radius + @firedAt.radius)

  bounceOffShips: () ->
    if @wouldHitTarget(@nextPos())
      @firedAt.takeDamage @damage, 'by hot plasma death'
      window.game.flash(@color)
      @destroy()

  bounceOffWalls: () ->
    newP = @nextPos()
    @destroy() if ((newP[0] - @radius) < 0) or                   
                ((newP[0] + @radius) > @r.width) or
                ((newP[1] - @radius) < 0) or
                ((newP[1] + @radius) > @r.height)
      
    
