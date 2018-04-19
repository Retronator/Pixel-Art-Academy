LOI = LandsOfIllusions

class LOI.Settings
  constructor: ->
    @persistSettings = new @constructor.ConsentField 'persistSettings'
    @persistGameState = new @constructor.ConsentField 'persistGameState', @persistSettings
    @persistCommandHistory = new @constructor.ConsentField 'persistCommandHistory', @persistSettings
    @persistLogin = new @constructor.ConsentField 'persistLogin', @persistSettings

    # By default, we disallow all but persisting settings.
    @persistGameState.disallow() unless @persistGameState.decided()
    @persistCommandHistory.disallow() unless @persistCommandHistory.decided()
    @persistLogin.disallow() unless @persistLogin.decided()

    @graphics =
      minimumScale: new @constructor.Field 2, 'graphics.minimumScale', @persistSettings
      maximumScale: new @constructor.Field null, 'graphics.maximumScale', @persistSettings
