window.keyPresses = {}

$ ->
  $(window).keydown (e) ->
    keyPresses[e.keyCode] = true
  $(window).keyup (e) ->
    delete keyPresses[e.keyCode]
