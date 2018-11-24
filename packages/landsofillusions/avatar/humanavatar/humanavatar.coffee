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

  destroy: ->
    super arguments...

    @_renderer?.stop()
    @_renderObject?.destroy()
    
  getRenderer: ->
    return @_renderer() if @_renderer
    
    @_renderer = new ComputedField => 
      @createRenderer()
    ,
      true

  createRenderer: (options) ->
    new LOI.Character.Avatar.Renderers.HumanAvatar _.extend({}, options, humanAvatar: @), true

  getRenderObject: ->
    return @_renderObject if @_renderObject

    Tracker.nonreactive =>
      @_renderObject = new @constructor.RenderObject @

    @_renderObject
