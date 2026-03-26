AEc = Artificial.Echo
AB = Artificial.Base
LOI = LandsOfIllusions

class LOI.Settings
  @id: -> 'LandsOfIllusions.Settings'
  
  @Audio =
    Enabled:
      Off: 'Off'
      Fullscreen: 'Fullscreen'
      On: 'On'
    
    InGameMusicOutput:
      InLocation: 'InLocation'
      Dynamic: 'Dynamic'
      Direct: 'Direct'
    
    mainVolume: new AEc.Variable "#{@id()}.audio.mainVolume", AEc.ValueTypes.Number
    soundVolume: new AEc.Variable "#{@id()}.audio.soundVolume", AEc.ValueTypes.Number
    ambientVolume: new AEc.Variable "#{@id()}.audio.ambientVolume", AEc.ValueTypes.Number
    musicVolume: new AEc.Variable "#{@id()}.audio.musicVolume", AEc.ValueTypes.Number
    inLocationMusicVolume: new AEc.Variable "#{@id()}.audio.inLocationMusicVolume", AEc.ValueTypes.Number
    inLocationMusicBandpassQ: new AEc.Variable "#{@id()}.audio.inLocationMusicBandpassQ", AEc.ValueTypes.Number
    
  @Controls =
    RightClick:
      None: 'None'
      Eraser: 'Eraser'
      BackButton: 'BackButton'
    
  constructor: ->
    @persistSettings = new @constructor.ConsentField
      name: 'persistSettings'
      question: "Do you want to save game settings also for next time?"
      moreInfo: "This will use your browser's local storage to save the settings between your play sessions."

    @persistGameState = new @constructor.ConsentField
      name: 'persistGameState'
      persistDecision: @persistSettings
      question: "Do you want to save your game?"
      moreInfo: "This will use your browser's local storage to save your progress in the game until you sign in.
                 After you're signed in, it will also keep you synced with your game character between play sessions,
                 and enable multiple players to use the same user account."

    @persistCommandHistory = new @constructor.ConsentField
      name: 'persistCommandHistory'
      persistDecision: @persistSettings
      question: "Do you want to keep the history of entered commands?"
      moreInfo: "This will use your browser's local storage to persist previously typed commands between game sessions."

    @persistLogin = new @constructor.ConsentField
      name: 'persistLogin'
      persistDecision: @persistSettings
      question: "Do you want to be automatically signed in?"
      moreInfo: "This will use your browser's local storage to store a sign-in token so that you don't need
                 to sign in again next time. Note: this will take effect after your next sign in."

    @persistEditorsInterface = new @constructor.ConsentField
      name: 'persistEditorsInterface'
      question: "Do you want to automatically save changes made to the user interface?"
      moreInfo: "This will use your browser's local storage to save editor settings."
      
    if AB.ApplicationEnvironment.isBrowser
      # In the browser, we disallow all but persisting settings by default.
      @persistGameState.disallow() unless @persistGameState.decided()
      @persistCommandHistory.disallow() unless @persistCommandHistory.decided()
      @persistLogin.disallow() unless @persistLogin.decided()
      @persistEditorsInterface.disallow() unless @persistEditorsInterface.decided()
      
    else
      # In standalone apps, consent is implied.
      @persistSettings.allow() unless @persistSettings.decided()
      @persistGameState.allow() unless @persistGameState.decided()
      @persistCommandHistory.allow() unless @persistCommandHistory.decided()
      @persistLogin.allow() unless @persistLogin.decided()
      @persistEditorsInterface.allow() unless @persistEditorsInterface.decided()

    @graphics =
      preferFullscreen: new @constructor.Field true, 'graphics.preferFullscreen', @persistSettings
      minimumScale: new @constructor.Field 2, 'graphics.minimumScale', @persistSettings
      maximumScale: new @constructor.Field null, 'graphics.maximumScale', @persistSettings
      anisotropicFilteringSamples: new @constructor.Field 16, 'graphics.anisotropicFilteringSamples', @persistSettings
      smoothShading: new @constructor.Field true, 'graphics.smoothShading', @persistSettings
      smoothShadingQuantizationLevels: new @constructor.Field 24, 'graphics.smoothShadingQuantizationLevels', @persistSettings
      crtEmulation: new @constructor.Field true, 'graphics.crtEmulation', @persistSettings
      slowCPUEmulation: new @constructor.Field true, 'graphics.slowCPUEmulation', @persistSettings

    audioDefault = if AB.ApplicationEnvironment.isBrowser then @constructor.Audio.Enabled.Fullscreen else @constructor.Audio.Enabled.On
    
    @audio =
      enabled: new @constructor.Field audioDefault, 'audio.enabled', @persistSettings
      inGameMusicOutput: new @constructor.Field @constructor.Audio.InGameMusicOutput.Dynamic, 'audio.inGameMusicOutput', @persistSettings
      mainVolume: new @constructor.Field 1, 'audio.mainVolume', @persistSettings
      soundVolume: new @constructor.Field 1, 'audio.soundVolume', @persistSettings
      ambientVolume: new @constructor.Field 1, 'audio.ambientVolume', @persistSettings
      musicVolume: new @constructor.Field 1, 'audio.musicVolume', @persistSettings
      inLocationMusicVolume: new @constructor.Field 0.3, 'audio.inLocationMusicVolume', @persistSettings
      inLocationMusicBandpassQ: new @constructor.Field 0.5, 'audio.inLocationMusicBandpassQ', @persistSettings
      
    @controls =
      rightClick: new @constructor.Field @constructor.Controls.RightClick.Eraser, 'controls.rightClick', @persistSettings

    # Update audio variables.
    Tracker.autorun =>
      for audioTypeName in ['main', 'sound', 'ambient', 'music', 'inLocationMusic']
        variableName = "#{audioTypeName}Volume"
        @constructor.Audio[variableName] @audio[variableName].value()
      
      for variableName in ['inLocationMusicBandpassQ']
        @constructor.Audio[variableName] @audio[variableName].value()
        
  toObject: ->
    values = {}

    for category in ['graphics']
      values[category] = {}

      for fieldName, field of @[category]
        values[category][fieldName] = field.value()

    values
