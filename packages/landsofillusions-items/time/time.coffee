AB = Artificial.Babel
LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Items.Time extends LOI.Adventure.Item
  @id: -> 'LandsOfIllusions.Items.Time'

  @fullName: -> "the time"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name

  @initialize()

  @defaultScriptUrl: -> 'retronator_landsofillusions-items/time/time.script'

  isVisible: -> false

  # Listener

  onCommand: (commandResponse) ->
    time = @options.parent
  
    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.WhatIs, time]
      priority: 1
      action: =>
        date = new Date()
        gameDate = LOI.adventure.gameTime()

        date.setHours gameDate.getHours(), gameDate.getMinutes(), gameDate.getSeconds()
        
        @script.ephemeralState 'timeString', date.toLocaleTimeString AB.currentLanguage(),
          hour: 'numeric'
          minute: 'numeric'

        @startScript label: 'WhatTime'
