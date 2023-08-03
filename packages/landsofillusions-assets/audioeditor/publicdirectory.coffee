AB = Artificial.Base
AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.PublicDirectory
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.PublicDirectory'
  
  @allSoundFiles = new AB.Subscription "#{@id().allSoundFiles}"

  @soundFiles = new AM.Collection "#{@id().filesAndDirectories}";
