AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Challenges.Drawing.PixelArtSoftware.ReferenceSelection extends PAA.Challenges.Drawing.ReferenceSelection
  @id: -> "PixelArtAcademy.Challenges.Drawing.PixelArtSoftware.ReferenceSelection"

  @displayName: -> "Choose a sprite to copy"

  @description: -> """
    To make sure you are ready to complete pixel art drawing assignments, this challenge requires you to copy an
    existing game sprite.
  """
  
  @portfolioComponentClass: -> @PortfolioComponent
  @customComponentClass: -> @CustomComponent
  
  @initialize()
  
  urlParameter: -> 'select-pixel-art-software-reference'
  
  width: -> 31
  height: -> 48
