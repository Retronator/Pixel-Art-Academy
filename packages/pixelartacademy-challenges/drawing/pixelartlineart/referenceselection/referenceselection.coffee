AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtLineArt.ReferenceSelection extends PAA.Challenges.Drawing.ReferenceSelection
  @id: -> "PixelArtAcademy.Challenges.Drawing.PixelArtLineArt.ReferenceSelection"

  @displayName: -> "Choose a reference to draw"

  @description: -> """
    Find a favorite character to draw fan art of.
  """

  @portfolioComponentClass: -> @PortfolioComponent
  @customComponentClass: -> @CustomComponent
  
  @initialize()
  
  urlParameter: -> 'select-pixel-art-line-art-reference'
  
  width: -> 63
  height: -> 81
