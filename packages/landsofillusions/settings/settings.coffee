LOI = LandsOfIllusions

class LOI.Settings
  @Audio:
    Enabled:
      Off: 'Off'
      Fullscreen: 'Fullscreen'
      On: 'On'
      
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

    # By default, we disallow all but persisting settings.
    @persistGameState.disallow() unless @persistGameState.decided()
    @persistCommandHistory.disallow() unless @persistCommandHistory.decided()
    @persistLogin.disallow() unless @persistLogin.decided()
    @persistEditorsInterface.disallow() unless @persistEditorsInterface.decided()

    @graphics =
      minimumScale: new @constructor.Field 2, 'graphics.minimumScale', @persistSettings
      maximumScale: new @constructor.Field null, 'graphics.maximumScale', @persistSettings
      
    @audio =
      enabled: new @constructor.Field @constructor.Audio.Enabled.Fullscreen, 'audio.enabled', @persistSettings
      soundVolume: new @constructor.Field 100, 'audio.soundVolume', @persistSettings
      musicVolume: new @constructor.Field 100, 'audio.musicVolume', @persistSettings

  toObject: ->
    values = {}

    for category in ['graphics']
      values[category] = {}

      for fieldName, field of @[category]
        values[category][fieldName] = field.value()

    values
