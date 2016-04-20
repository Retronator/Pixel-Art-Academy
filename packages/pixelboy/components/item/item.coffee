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

  $pixelboy: ->
    @$('.pixelboy')

  activatedClass: ->
    'activated' if @pixelBoy.activated()

  pixelBoyStyle: ->
    # This determines the visual size of the PixelBoy (its screen/OS area).
    width: "#{@width()}rem"
    height: "#{@height()}rem"

  osIframeAttributes: ->
    # This will determine the pixel-backing size of the canvas.
    width: @width()
    height: @height()

  events: ->
    super.concat
      'click .deactivate-button': @onClickDeactivateButton

  onClickDeactivateButton: (event) ->
    @pixelBoy.deactivate()

  draw: (appTime) ->
    # Any component based draw routines can go here.
