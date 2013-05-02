window.keyPresses ||= {}

drawPaper = ->
  paper = window.game.r

  controlSpacingX = paper.width / 20.0
  controlSpacingY = paper.height / 10.0
  midway = paper.width / 2.0

  x = (n) -> controlSpacingX * n
  y = (n) -> controlSpacingY * n

  configure = (e, color, number) ->
    fn = (tf) ->
      return () ->
        window.keyPresses[number] = tf
        game.inputEvent() if game.inputEvent
    e.
      attr(fill: color, "fill-opacity": 0.2).
      touchstart(fn true).
      touchend(  fn false).
      mousedown( fn true).
      mouseup(   fn false)

  # P1
  left = paper.rect(midway + x(1), y(4), x(2), y(2), 10)
  configure(left, window.game.p1.color, 65)

  right = paper.rect(midway + x(7), y(4), x(2), y(2), 10)
  configure(right, window.game.p1.color, 68)

  up = paper.rect(midway + x(4), y(1), x(2), y(2), 10)
  configure(up, window.game.p1.color, 87)

  down = paper.rect(midway + x(4), y(7), x(2), y(2), 10)
  configure(down, window.game.p1.color, 83)

  shoot = paper.rect(midway + x(4), y(4), x(2), y(2), 10)
  configure(shoot, window.game.p1.color, 113)

  # P2
  left = paper.rect(x(1), y(4), x(2), y(2), 10)
  configure(left, window.game.p2.color, 37)

  right = paper.rect(x(7), y(4), x(2), y(2), 10)
  configure(right, window.game.p2.color, 39)

  up = paper.rect(x(4), y(1), x(2), y(2), 10)
  configure(up, window.game.p2.color, 38)

  down = paper.rect(x(4), y(7), x(2), y(2), 10)
  configure(down, window.game.p2.color, 40)

  shoot = paper.rect(x(4), y(4), x(2), y(2), 10)
  configure(shoot, window.game.p2.color, 46)

$ ->
  game = window.game
  game.onInit = ->
    @replayMessage = ""
    drawPaper()
    @onLose = () ->
      @.inputEvent = ->
        @newGame()

  game.onInit()

oldheight = window.furiousEarth.HEIGHT
oldwidth = window.furiousEarth.WIDTH
window.furiousEarth.WIDTH = $(window).width()
window.furiousEarth.HEIGHT = $(window).height()
window.furiousEarth.BORDER = 0

scale = Math.max(oldheight / $(window).height(), oldwidth / $(window).width())

window.furiousEarth.DEFAULT_WIDGET_RADIUS = 25 / scale
window.furiousEarth.NIMBLE_SHIP_OUTER_RADIUS = 20 / scale
window.furiousEarth.SHIP_INNER_RADIUS = 5 / scale
window.furiousEarth.BULLET_RADIUS = 3 / scale

window.furiousEarth.SCALE = scale
