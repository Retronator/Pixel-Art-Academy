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

    @dataReady = new ComputedField =>
      # Human avatar has data ready when both body and outfit have a document in them.
      @body.options.dataLocation.options.rootField.options.load()? and @outfit.options.dataLocation.options.rootField.options.load()?

  destroy: ->
    super arguments...

    @_renderer?.destroy()
    @_renderObject?.destroy()

    @dataReady.stop()
    
  getRenderer: ->
    @_renderer ?= Tracker.nonreactive => @createRenderer()
    @_renderer

  createRenderer: (options) ->
    new LOI.Character.Avatar.Renderers.HumanAvatar _.extend({}, options, humanAvatar: @), true

  getRenderObject: ->
    @_renderObject ?= Tracker.nonreactive => new @constructor.RenderObject @
    @_renderObject
