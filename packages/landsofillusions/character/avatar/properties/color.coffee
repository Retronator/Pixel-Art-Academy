LOI = LandsOfIllusions

class LOI.Character.Avatar.Properties.Color extends LOI.Character.Part.Property
  # node
  #   fields
  #     hue
  #       value
  #     shade
  #       value
  #     reflection
  #       node
  #         fields
  #           intensity
  #             value
  #           shininess
  #             value
  #           smoothFactor
  #             value
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
    reflectionNode = colorNode? 'reflection'
    reflectionData = reflectionNode?.data()

    if reflectionData?.fields
      reflection =
        intensity: reflectionData.fields.intensity?.value
        shininess: reflectionData.fields.shininess?.value
        smoothFactor: reflectionData.fields.smoothFactor?.value

    reflection or @options.default?.reflection
