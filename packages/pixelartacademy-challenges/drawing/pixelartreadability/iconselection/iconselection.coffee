AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtReadability.IconSelection extends PAA.Challenges.Drawing.ReferenceSelection
  @id: -> "PixelArtAcademy.Challenges.Drawing.PixelArtReadability.IconSelection"

  @displayName: -> "The Graphics Book of Icons"

  @description: -> """
    Successfully draw at least one 16×16 icon in the book to complete the challenge.
  """

  @portfolioComponentClass: -> @PortfolioComponent
  @customComponentClass: -> @CustomComponent
  
  @initialize()
  
  urlParameter: -> 'the-graphics-book-of-icons'
  
  width: -> 56
  height: -> 82
