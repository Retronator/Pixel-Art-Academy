AB = Artificial.Base
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Artworks
  @id: -> 'PixelArtAcademy.Practice.Artworks'
  
  @insert = new AB.Method name: "#{@id()}.insert"
  
  @maxSizes =
    Sprite: 64
    Bitmap: 4096
