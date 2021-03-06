window.furiousEarth.Game = class Game
  constructor: (@keypresses) ->
    self = this
    if window.furiousEarth.BORDER > 0
      @r = Raphael(20, 20, window.furiousEarth.WIDTH, window.furiousEarth.HEIGHT)
    else
      @r = Raphael(0, 0, window.furiousEarth.WIDTH, window.furiousEarth.HEIGHT)
    @border = @r.rect(window.furiousEarth.BORDER, window.furiousEarth.BORDER, window.furiousEarth.WIDTH - window.furiousEarth.BORDER, window.furiousEarth.HEIGHT - window.furiousEarth.BORDER).attr({stroke: "red"})
    @p2 = new window.furiousEarth.Ship(@r, position: [window.furiousEarth.WIDTH * 0.25, window.furiousEarth.HEIGHT * 0.25], mass: 15, radius: furiousEarth.NIMBLE_SHIP_OUTER_RADIUS, shotProfile: [10, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 35, 50, 80], name: "The Flash", topSpeed: 5, accell: 2.4, color: "yellow")
    @p1 = new window.furiousEarth.Ship(@r, position: [window.furiousEarth.WIDTH * 0.75, window.furiousEarth.HEIGHT * 0.75], mass: 26, name: 'Blue Bertha', accell: 1.8, color: "lightblue")

    @status = @r.text(0, 150 / window.furiousEarth.SCALE, '').attr(fill: "white", 'font-size': ("" + 40 / window.furiousEarth.SCALE))
    @status.attr('x': (window.furiousEarth.WIDTH - @status.getBBox().width) / 2)
    # TODO: yuk yukkity yuk.
    @p1.otherShip = @p2
    @p2.otherShip = @p1

    window.myinterval = setInterval((-> self.tick()), window.furiousEarth.GAME_TICK)

  destroy: ->
    @r.clear()
    $(@r.node).remove()
    @onDestroy() if @onDestroy

  newGame: ->
    window.game.destroy()
    window.game = new Game(@keypresses)
    window.game.onDestroy = @onDestroy
    window.game.onInit = @onInit
    window.game.onInit()
    window.game

  replayMessage: ""

  lose: (ship) ->
    @status.attr(text: "#{ship.name} was destroyed\n #{ship.damageMsg}\n#{@replayMessage}")
    ship.set.remove()
    clearTimeout(window.myinterval)
    @onLose() if @onLose

  flash: (color='pink') ->
    window.game.border.attr('stroke', color)
    setTimeout((-> window.game.border.attr('stroke', 'red')), 30)

  shooting: {
    p1: 113
    p2: 46
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

    for num in [1..(window.furiousEarth.SPEED)]
      p1Acc.adjust(value) for key, value of @movement.p1 when @keypresses[key]
      p2Acc.adjust(value) for key, value of @movement.p2 when @keypresses[key]

    self = this
    $(window).keypress (e) ->
      if self.shooting.p1 == (e.keyCode || e.charCode)
        self.p1.shoot("main")
      if self.shooting.p2 == (e.keyCode || e.charCode)
        self.p2.shoot("main")

    if @keypresses[@shooting.p1]
      @keypresses[@shooting.p1] = false
      self.p1.shoot('main')
    if @keypresses[@shooting.p2]
      @keypresses[@shooting.p2] = false
      self.p2.shoot('main')

    @p1.accellerate(p1Acc)
    @p2.accellerate(p2Acc)
    @p1.collisions()
    @p2.collisions()
    @p1.move()
    @p2.move()

    @status.attr text: "#{@p1.name}: #{@p1.health} vs #{@p2.name}: #{@p2.health}"
    @lose(@p1) if @p1.health <= 0
    @lose(@p2) if @p2.health <= 0

$ ->
  window.game = new Game(window.keyPresses)
