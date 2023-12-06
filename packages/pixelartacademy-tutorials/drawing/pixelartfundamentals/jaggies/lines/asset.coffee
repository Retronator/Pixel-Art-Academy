LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.Asset extends PAA.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Asset
  @id: -> "PixelArtAcademy.Tutorials.Drawing.PixelArtFundamentals.Jaggies.Lines.#{_.pascalCase @displayName()}"

  @svgUrl: -> "/pixelartacademy/tutorials/drawing/pixelartfundamentals/jaggies/lines/#{_.fileCase @displayName()}.svg"
  
  @breakPathsIntoSteps: -> true
