LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class C1.Airship.Tower extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Airship.Tower'

  @location: -> RS.Tower.Atrium2ndLevel

  @initialize()

  things: ->
    [
      C1.Actors.Alex
    ]

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter1/sections/airship/scenes/tower.script'

  initializeScript: ->
    @setCurrentThings alex: C1.Actors.Alex

  onCommand: (commandResponse) ->
    return unless alex = LOI.adventure.getCurrentThing C1.Actors.Alex
    @script.setThings {alex}

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, alex.avatar]
      priority: 1
      action: => @startScript label: 'TalkToAlex'

  onExitAttempt: (exitResponse) ->
    if exitResponse.destinationLocationClass isnt RS.AirshipTerminal.Terminal
      @startScript label: 'WrongWay'
      exitResponse.preventExit()
