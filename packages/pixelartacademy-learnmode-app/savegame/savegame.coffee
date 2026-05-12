AB = Artificial.Babel
AC = Artificial.Control
AEc = Artificial.Echo
AM = Artificial.Mirage
AT = Artificial.Telepathy
LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PAA.LearnMode

Persistence = Artificial.Mummification.Document.Persistence

class LM.SaveGame extends LOI.Components.SaveGame
  @id: -> 'PixelArtAcademy.LearnMode.SaveGame'
  @register @id()

  @initializeDataComponent()
  
  onCreated: ->
    super arguments...
    
    useSteamCloud = false
    
    if steam = AT.Steam.instance()
      if steam.cloud.enabledForAccount
        useSteamCloud = steam.cloud.enabledForApp()
    
    @steamCloud = new ReactiveField useSteamCloud
  
  saveGame: ->
    LOI.adventure.saveGame steamCloud: @steamCloud()
    
  optionsVisibleClass: ->
    'visible' if @newSaveGameName()
    
  steamCloudClass: ->
    'steam-cloud' if @steamCloud()

  # Components

  class @SteamCloud extends @DataInputComponent
    @register 'PixelArtAcademy.LearnMode.SaveGame.SteamCloud'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Checkbox
      @propertyName = 'steamCloud'
