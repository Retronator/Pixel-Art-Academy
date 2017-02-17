LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class C1.Immigration.BaggageClaim extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Immigration.BaggageClaim'

  @location: -> RS.AirportTerminal.BaggageClaim

  @translations: ->
    intro: "
      You enter a small room with a baggage carousel already unloading the bags from the flight.
      Your suitcase arrives shortly as well. The arrivals area is north through the customs.
    "

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter1/immigration/scenes/baggageclaim.script'

  @initialize()

  things: -> [
    C1.Suitcase unless C1.Suitcase.state 'inInventory'
    C1.Actors.Alex
  ]

  onEnter: (enterResponse) ->
    enterResponse.overrideIntroduction =>
      @options.parent.translations()?.intro

  onCommand: (commandResponse) ->
    alex = LOI.adventure.getCurrentThing C1.Actors.Alex
    @script.setThings {alex}

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt], alex.avatar]
      priority: 1
      action: => @startScript label: 'LookAtAlex'

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.TalkTo], alex.avatar]
      action: => @startScript label: 'TalkToAlex'

  onExitAttempt: (exitResponse) ->
    hasSuitcase = C1.Suitcase.state 'inInventory'
    return if hasSuitcase

    @startScript label: 'LeaveWithoutSuitcase'
    exitResponse.preventExit()
