AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Drawing.Portfolio.ImportArtwork extends PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.FormAsset
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Drawing.Portfolio.ImportArtwork'
  
  @type: -> @Types.None
  
  @displayName: -> "Import artwork"
  
  @description: -> """
      Import an artwork that was created with external software.
    """
  
  @initialize()

  constructor: ->
    super arguments...

    @portfolioComponent = new @constructor.PortfolioComponent @
    @clipboardComponent = new @constructor.ClipboardComponent @

  urlParameter: -> 'import'
