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

    @setFixedPixelBoySize 332, 241

    @portfolio = new ReactiveField null

  onCreated: ->
    super

    # Initialize components.
    @portfolio new @constructor.Portfolio @

  onBackButton: ->
    portfolio = @portfolio()

    # Normally quit if we don't have an active asset.
    return unless portfolio.activeAsset()

    portfolio.activeAsset null

    # Inform that we've handled the back button.
    true
