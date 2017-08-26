LOI = LandsOfIllusions

class LOI.Character.Avatar.Properties.Color extends LOI.Character.Part.Property
  # node
  #   fields
  #     hue
  #       value
  #     shade
  #       value
  constructor: (@options = {}) ->
    super

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

    # Compare for existence since hue can be 0.
    return shade if shade?

    @options.default?.shade
