AB = Artificial.Base
AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.PublicDirectory
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.PublicDirectory'
  
  @allSoundFiles = new AB.Subscription name: "#{@id()}.allSoundFiles"

  @soundFiles = new AM.Collection "#{@id()}.filesAndDirectories",
    transform: (document) ->
      document.itemType = 'Sound'
      document
