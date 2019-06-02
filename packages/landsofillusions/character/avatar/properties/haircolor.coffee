LOI = LandsOfIllusions

class LOI.Character.Avatar.Properties.HairColor extends LOI.Character.Avatar.Properties.Color
  # node
  #   fields
  #     hue
  #       value
  #     shade
  #       value
  #     shine
  #       value
  constructor: (@options = {}) ->
    super arguments...

    @type = 'hairColor'

  shine: ->
    colorNode = @options.dataLocation()
    shine = colorNode? 'shine'

    # Compare for existence since shade can be 0.
    return shine if shine?

    @options.default?.shine

  reflection: ->
    shine = @shine()
    return unless shine?

    shade = @shade()

    # To prevent overexposure we weaken reflection intensity proportional to shade lightness.
    intensity = (9 - shade) * shine / 100
    shininess = 5
    smoothFactor = 1

    {intensity, shininess, smoothFactor}
