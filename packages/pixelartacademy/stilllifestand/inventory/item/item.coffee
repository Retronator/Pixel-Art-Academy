AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StillLifeStand.Inventory.Item extends AM.Component
  @id: -> 'PixelArtAcademy.StillLifeStand.Inventory.Item'
  @register @id()

  constructor: ->
    super arguments...

    @$canvas = new ReactiveField null
    @canvas = new ReactiveField null
    @context = new ReactiveField null

  onCreated: ->
    super arguments...

    @_item = null

    @item = new ComputedField =>
      @_item?.destroy()

      itemData = @data()
      itemClass = _.thingClass itemData.type

      if itemData.type is itemData.id
        # If no special ID is given, we have a unique item.
        @_item = new itemClass

      else
        # Otherwise we need to get the specific copy for the ID.
        @_item = itemClass.getCopyForId itemData.id

      @_item

    @spriteData = new ComputedField =>
      return unless item = @item()

      spriteName = item.constructor.assetsPath()
      LOI.Assets.Sprite.findInCache name: spriteName

    @sprite = new LOI.Assets.Engine.Sprite
      spriteData: @spriteData

    @lightDirection = new ReactiveField new THREE.Vector3(0, -1, -1).normalize()

    # Redraw canvas routine.
    @autorun =>
      return unless canvas = @canvas()
      return unless context = @context()

      context.setTransform 1, 0, 0, 1, 0, 0
      context.clearRect 0, 0, canvas.width, canvas.height

      return unless spriteData = @spriteData()
      return unless spriteData.bounds

      canvas.width = spriteData.bounds.width
      canvas.height = spriteData.bounds.height

      context.translate -spriteData.bounds.left, -spriteData.bounds.top
      @sprite.drawToContext context, lightDirection: @lightDirection()

  onRendered: ->
    super arguments...

    # DOM has been rendered, initialize.
    $canvas = @$('.canvas')
    canvas = $canvas[0]

    @$canvas $canvas
    @canvas canvas
    @context canvas.getContext '2d'

  events: ->
    super(arguments...).concat
      'mousemove canvas': @onMouseMoveCanvas
      'mouseleave canvas': @onMouseLeaveCanvas

  onMouseMoveCanvas: (event) ->
    $canvas = @$canvas()

    canvasOffset = $canvas.offset()

    percentageX = (event.pageX - canvasOffset.left) / $canvas.outerWidth() * 2 - 1
    percentageY = (event.pageY - canvasOffset.top) / $canvas.outerHeight() * 2 - 1

    @lightDirection new THREE.Vector3(-percentageX, percentageY, -1).normalize()

  onMouseLeaveCanvas: (event) ->
    @lightDirection new THREE.Vector3(0, -1, -1).normalize()
