AM = Artificial.Mummification
LOI = LandsOfIllusions

# Game representation of a human.
class LOI.HumanAvatar extends LOI.Avatar
  constructor: (@options) ->
    super

    if @options.bodyDataField
      @body = LOI.Character.Part.Types.Avatar.Body.create
        dataLocation: new AM.Hierarchy.Location
          rootField: @options.bodyDataField

    if @options.outfitDataField
      @outfit = LOI.Character.Part.Types.Avatar.Outfit.create
        dataLocation: new AM.Hierarchy.Location
          rootField: @options.outfitDataField

  getRenderer: ->
    # Instantiate the renderer on first call.
    unless @_rendererSingleton
      @_rendererSingleton = new LOI.Character.Avatar.Renderers.HumanAvatar humanAvatar: @, true

    # Simply return the renderer.
    @_rendererSingleton
