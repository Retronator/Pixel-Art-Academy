LOI = LandsOfIllusions

class LOI.Character.Avatar.Properties.Color extends LOI.Character.Part.Property
  # node
  #   fields
  #     hue
  #       value
  #     shade
  #       value
  #     reflection
  #       value
  constructor: (@options = {}) ->
    super arguments...

    @type = 'color'

    return unless @options.dataLocation
    
  hue: ->
    colorNode = @options.dataLocation()
    hue = colorNode? 'hue'

    # Compare for existence since hue can be 0.
    return hue if hue?

    @options.default?.hue

  shade: ->
    colorNode = @options.dataLocation()
    shade = colorNode? 'shade'

    # Compare for existence since shade can be 0.
    return shade if shade?

    @options.default?.shade

  reflection: ->
    colorNode = @options.dataLocation()
    reflection = colorNode? 'reflection'

    # Compare for existence since shade can be 0.
    reflection or @options.default?.reflection
