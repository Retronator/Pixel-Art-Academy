AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing extends PAA.PixelBoy.OS.App
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing'

  displayName: ->
    "Drawing"

  keyName: ->
    'drawing'

  constructor: ->
    super

    @setDefaultPixelBoySize()

    @showHomeScreenButton false

    @isInSpriteSelection = new ReactiveField true

    @spriteCanvas = new ReactiveField null
    @navigator = new ReactiveField null
    @palette = new ReactiveField null
    @sprites = new ReactiveField null

    @spriteId = new ComputedField =>
      @sprites()?.spriteId()

    @spriteData = new ComputedField =>
      spriteId = @spriteId()
      LOI.Assets.Sprite.documents.findOne spriteId

  onCreated: ->
    # Initialize components.
    @spriteCanvas new @constructor.SpriteCanvas @
    @navigator new @constructor.Components.Navigator
      viewport: @spriteCanvas().camera

    @sprites new @constructor.Sprites @
    @palette new @constructor.Components.Palette
      paletteId: new ComputedField =>
        LOI.Assets.Sprite.documents.findOne(@spriteId(),
          fields:
            palette: 1
        )?.palette._id

    # Show home screen button when in sprite selection.
    @autorun =>
      @showHomeScreenButton @isInSpriteSelection()

  onRendered: ->
    super

    @autorun =>
      if @isInSpriteSelection()
        # Immediately remove the drawing active class so that the slow transitions kick in.
        @$('.apps-drawing').removeClass('drawing-active')

      else
        # Add the drawing active class with delay so that the initial transitions still happen slowly.
        Meteor.setTimeout =>
          @$('.apps-drawing').addClass('drawing-active')
        ,
          1000

  inSpriteSelectionClass: ->
    'in-sprite-selection' if @isInSpriteSelection()
