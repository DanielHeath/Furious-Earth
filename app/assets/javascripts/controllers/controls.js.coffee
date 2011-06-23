class Controls
  
  initialize: (options) ->
    @options = $.extend @default_options, options
  
  defaultOptions:
    keyPresses: window.keyPresses
