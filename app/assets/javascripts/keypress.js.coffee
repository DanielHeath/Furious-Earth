window.keyPresses = {}

$ ->
  $(window).keydown (e) ->
    keyPresses[e.keyCode] = true
  $(window).keyup (e) ->
    delete keyPresses[e.keyCode]

$ ->
  game = window.game
  game.onInit = ->
    @replayMessage = "(blue press fire to play again)"
    @onLose = () ->
      $(window).unbind('keypress')
      $(window).keypress (e) =>
        if @shooting.p1 == e.keyCode or @shooting.p2 == e.keyCode
          game = @newGame()
          if @shooting.p2 == e.keyCode
            [game.p1, game.p2] = [game.p2, game.p1]
          $(window).unbind('keypress')

  game.onInit()
