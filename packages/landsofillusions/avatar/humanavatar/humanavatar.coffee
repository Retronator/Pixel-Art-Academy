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

    # Destroy rendering systems.
    @_renderer?.destroy()
    @_renderObject?.destroy()

    # Destroy parts.
    @body?.destroy()
    @outfit?.destroy()

    # Destroy data hierarchy.
    @options.bodyDataField?.destroy()
    @options.outfitDataField?.destroy()

    @dataReady.stop()
    
  getRenderer: ->
    @_renderer ?= Tracker.nonreactive => @createRenderer()
    @_renderer

  createRenderer: (options) ->
    console.log "Creating human avatar renderer", @ if LOI.debug
    new LOI.Character.Avatar.Renderers.HumanAvatar _.extend({}, options, humanAvatar: @), true

  getRenderObject: ->
    @_renderObject ?= Tracker.nonreactive =>
      console.log "Creating human avatar render object", @ if LOI.debug
      new @constructor.RenderObject @

    @_renderObject

  getPhysicsObject: ->
    @_physicsObject ?= Tracker.nonreactive =>
      console.log "Creating human avatar physics object", @ if LOI.debug
      new @constructor.PhysicsObject @

    @_physicsObject
