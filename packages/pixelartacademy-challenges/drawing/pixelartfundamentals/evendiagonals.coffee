AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAG = PAA.Practice.PixelArtEvaluation

class PAA.Challenges.Drawing.PixelFundamentals.EvenDiagonals extends PAA.Challenges.Drawing.PixelFundamentals.Asset
  @id: -> 'PixelArtAcademy.Challenges.Drawing.PixelFundamentals.EvenDiagonals'
  
  @displayName: -> "Even diagonals"
  
  @description: -> """
    Adjust the image to use only even diagonals.
  """
  
  @criterion: -> PAA.Practice.PixelArtEvaluation.Criteria.EvenDiagonals
  
  Asset = @
  
  class @EnableEvaluation extends PAA.Challenges.Drawing.PixelFundamentals.EnableEvaluation
    @id: -> "#{Asset.id()}.EnableEvaluation"
    
    @criterion: -> PAA.Practice.PixelArtEvaluation.Criteria.EvenDiagonals
