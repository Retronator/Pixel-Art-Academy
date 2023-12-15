AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAG = PAA.Practice.PixelArtGrading

class PAA.Challenges.Drawing.PixelFundamentals.EvenDiagonals extends PAA.Challenges.Drawing.PixelFundamentals.Asset
  @id: -> 'PixelArtAcademy.Challenges.Drawing.PixelFundamentals.EvenDiagonals'
  
  @displayName: -> "Even diagonals"
  
  @description: -> """
    Adjust the image to use only even diagonals.
  """
  
  @criterion: -> PAA.Practice.PixelArtGrading.Criteria.EvenDiagonals
  
  Asset = @
  
  class @EnableGrading extends PAA.Challenges.Drawing.PixelFundamentals.EnableGrading
    @id: -> "#{Asset.id()}.EnableGrading"
    
    @criterion: -> PAA.Practice.PixelArtGrading.Criteria.EvenDiagonals
