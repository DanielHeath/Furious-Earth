window.furiousEarth.GameBoard = class GameBoard
  constructor: () ->
    self = this
    @r = Raphael(20, 20, 800, 600)
    @border = @r.rect(2, 2, 798, 598).attr({stroke: "red"})
    @status = @r.text( 400, 150, '').attr(fill: "white", 'font-size': '40')

  
