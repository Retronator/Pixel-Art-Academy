LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

class C1.Airship.Tower extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Airship.Tower'

  @location: -> RS.Tower.Atrium2ndLevel

  @listeners: -> [
    @Listener
  ]

  @initialize()

  things: ->
    [
      C1.Actors.Alex
    ]

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter1/airship/scenes/tower.script'

  initializeScript: ->
    @setCurrentThings alex: C1.Actors.Alex
    
  onExitAttempt: (exitResponse) ->
    if exitResponse.destinationLocationClass isnt RS.AirshipTerminal.Terminal
      @startScript label: 'WrongWay'
      exitResponse.preventExit()
