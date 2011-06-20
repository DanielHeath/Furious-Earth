$ ->
  Array::copy = ->
    e for e in @
    
  Array::adjust = (other) ->
    for i in [0..(@length - 1)]
      @[i] += other[i]

  Array::jiggle = () ->
    for i in [0..(@length - 1)]
      @[i] += (Math.random() * 4) - 2

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

