AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelBoy.Components.Item extends AM.Component
  @register "PixelArtAcademy.PixelBoy.Components.Item"

  constructor: (@pixelBoy) ->
    # The actual current width and height of the physical device (measured as the inner screen/OS area).
    @width = new ReactiveField 240
    @height = new ReactiveField 180

    # The minimum size the device should be let to resize.
    @minWidth = new ReactiveField 100
    @minHeight = new ReactiveField 100

    # The maximum size the device should be let to resize.
    @maxWidth = new ReactiveField 300
    @maxHeight = new ReactiveField 200

    @resizable = new ReactiveField false
    @resizing = new ReactiveField false

    @startResizeX = new ReactiveField null
    @startResizeY = new ReactiveField null
    @startWidth = new ReactiveField null
    @startHeight = new ReactiveField null

    @endResizeX = new ReactiveField null
    @endResizeY = new ReactiveField null

  onRendered: ->
    super

    $(window).on('mousemove.pixelboy', (event) => @onMousemove(event))
    $(window).on('mouseup.pixelboy', (event) => @onMouseup(event))

    @autorun =>
      return unless @resizing()
      scale = @pixelBoy.adventure.display.scale()
      newWidth = @startWidth() + (@endResizeX() - @startResizeX())/scale
      newHeight = @startHeight() - (@endResizeY() - @startResizeY())/scale
      newWidth = Math.min @maxWidth(), Math.max @minWidth(), newWidth
      newHeight = Math.min @maxHeight(), Math.max @minHeight(), newHeight
      @width newWidth
      @height newHeight

  onDestroyed: ->
    super

    $(window).off('.pixelboy')

  $pixelboy: ->
    @$('.pixelboy')

  activatedClass: ->
    'activated' if @pixelBoy.activating() or @pixelBoy.activated()

  pixelBoyStyle: ->
    # This determines the visual size of the PixelBoy (its screen/OS area).
    width: "#{@width()}rem"
    height: "#{@height()}rem"

  osIframeAttributes: ->
    app = FlowRouter.getParam 'parameter2'
    path = FlowRouter.getParam 'parameter3'

    # This will determine the pixel-backing size of the canvas.
    width: @width()
    height: @height()
    src: FlowRouter.path 'pixelBoy', app: app, path: path

  osIframeStyle: ->
    'pointer-events': if @resizing() then 'none' else 'initial'

  events: ->
    super.concat
      'click .deactivate-button': @onClickDeactivateButton
      'mouseover .glass': @onMouseoverGlass
      'mouseout .glass': @onMouseoutGlass
      'mousedown': @onMousedown

  onMouseoverGlass: (event) ->
    @resizable true
    $('.glass').addClass('resizable')

  onMouseoutGlass: (event) ->
    @resizable false
    $('.glass').removeClass('resizable')

  onMousedown: (event) ->
    event.preventDefault()
    # get current x and y pos
    if @resizable()
      @startResizeX event.clientX
      @startResizeY event.clientY
      @endResizeX event.clientX
      @endResizeY event.clientY
      @startWidth @width()
      @startHeight @height()
      @resizing true

  onMousemove: (event) ->
    return unless @resizing()
    @endResizeX event.clientX
    @endResizeY event.clientY

  onMouseup: (event) ->
    @resizing false

  onClickDeactivateButton: (event) ->
    @pixelBoy.deactivate()

  draw: (appTime) ->
    # Any component based draw routines can go here.
