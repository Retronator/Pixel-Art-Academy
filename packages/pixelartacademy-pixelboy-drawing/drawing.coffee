AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing extends PAA.PixelBoy.App
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing'
  @url: -> 'drawing'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Drawing"
  @description: ->
    "
      It's the app for drawing pixel art.
    "
    
  @initialize()

  constructor: ->
    super

    @portfolio = new ReactiveField null
    @clipboard = new ReactiveField null

  onCreated: ->
    super

    # Initialize components.
    @portfolio new @constructor.Portfolio @
    @clipboard new @constructor.Clipboard @

    @autorun (computation) =>
      portfolio = @portfolio()
      clipboard = @clipboard()

      if portfolio.isCreated() and portfolio.activeAsset()
        if clipboard.editorActive()
          @setMaximumPixelBoySize fullscreen: true

        else
          @setFixedPixelBoySize 200, 260

      else
        @setFixedPixelBoySize 332, 241
