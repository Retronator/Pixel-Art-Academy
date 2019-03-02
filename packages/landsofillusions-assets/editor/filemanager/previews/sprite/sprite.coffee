AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager.Previews.Sprite extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Editor.FileManager.Previews.Sprite'
  @register @id()

  constructor: ->
    super arguments...

    @$canvas = new ReactiveField null
    @canvas = new ReactiveField null
    @context = new ReactiveField null

  onCreated: ->
    super arguments...

    @spriteData = new ComputedField =>
      sprite = @data()

      # Get full sprite data.
      LOI.Assets.Asset.forId.subscribe @, LOI.Assets.Sprite.className, sprite._id
      LOI.Assets.Sprite.documents.findOne sprite._id

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
