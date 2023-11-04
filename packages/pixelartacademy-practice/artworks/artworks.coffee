AB = Artificial.Base
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Artworks
  @id: -> 'PixelArtAcademy.Practice.Artworks'
  
  @insert = new AB.Method name: "#{@id()}.insert"
  
  @maxSize = 4096
