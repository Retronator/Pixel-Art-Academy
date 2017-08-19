LOI = LandsOfIllusions

class LOI.Character.Avatar.Properties.Sprite extends LOI.Character.Part.Property
  # node
  #   fields
  #     spriteId: ID of the sprite document
  #       value
  constructor: (@options = {}) ->
    super

    @type = 'sprite'

    return unless @options.dataLocation
