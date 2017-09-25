LOI = LandsOfIllusions

class LOI.Character.Avatar.Properties.RelativeColorShade extends LOI.Character.Part.Property
  constructor: (@options = {}) ->
    super

    @type = 'relativeColorShade'

    return unless @options.dataLocation

  hue: ->
    # Hue remains the same.
    @options.baseColor(@options.parent).hue()

  baseShade: ->
    @options.baseColor(@options.parent).shade()

  relativeShade: ->
    @options.dataLocation() or 0

  shade: ->
    # Add relative shade to the base shade.
    return unless baseShade = @baseShade()

    baseShade + @relativeShade()
