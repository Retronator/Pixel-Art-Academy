AM = Artificial.Mummification
LOI = LandsOfIllusions

# Game representation of a human.
class LOI.HumanAvatar extends LOI.Avatar
  constructor: (@options) ->
    super arguments...

    if @options.bodyDataField
      @body = LOI.Character.Part.Types.Avatar.Body.create
        dataLocation: new AM.Hierarchy.Location
          rootField: @options.bodyDataField

    if @options.outfitDataField
      @outfit = LOI.Character.Part.Types.Avatar.Outfit.create
        dataLocation: new AM.Hierarchy.Location
          rootField: @options.outfitDataField

    # Create renderer for drawing this part's hierarchy.
    @renderer = new ComputedField =>
      new LOI.Character.Avatar.Renderers.HumanAvatar humanAvatar: @, true
    ,
      true

    # We need another renderer for drawing the texture.
    @textureRenderers = []
    
    for sideIndex in [0..7]
      do (sideIndex) =>
        @textureRenderers.push new ComputedField =>
          new LOI.Character.Avatar.Renderers.HumanAvatar
            humanAvatar: @
            renderTexture: true
            viewingAngle: =>
              sideIndex * Math.PI / 4
            ,
              true
          ,
            true

  destroy: ->
    super arguments...

    @renderer.stop()
    renderer.sotp() for renderer in @textureRendeders()
