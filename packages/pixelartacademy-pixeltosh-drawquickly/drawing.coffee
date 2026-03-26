AE = Artificial.Everywhere
AM = Artificial.Mummification
PAA = PixelArtAcademy
DrawQuickly = PAA.Pixeltosh.Programs.DrawQuickly

class DrawQuickly.Drawing extends AM.Document
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.DrawQuickly.Drawing'
  # profileId: the profile that completed the task
  # lastEditTime: the time when task was completed
  # strokes: array the strokes the player has drawn for this duration
  #   []: an array of coordinates in this stroke
  #     x, y: coordinates in the 100x100 source image
  @Meta
    name: @id()
      
  @enablePersistence()
  
  @save: (strokes) ->
    @documents.insert
      profileId: LOI.adventure.profileId()
      lastEditTime: new Date()
      strokes: strokes
