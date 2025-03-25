AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Portfolio.NewArtwork extends PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.Forms.Asset
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.NewArtwork'
  
  @type: -> @Types.None
  
  @displayName: -> "New artwork"
  
  @description: -> """
      Create a new artwork that you will edit with the built-in editor.
    """
  
  @initialize()

  constructor: ->
    super arguments...
  
    @portfolioComponent = new @constructor.PortfolioComponent @
    @clipboardComponent = new @constructor.ClipboardComponent @

  urlParameter: -> 'new'
