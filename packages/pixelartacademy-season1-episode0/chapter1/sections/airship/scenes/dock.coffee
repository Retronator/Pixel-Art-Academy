LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class C1.Airship.Dock extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Airship.Dock'

  @location: -> RS.AirshipTerminal.Dock

  @initialize()

  things: ->
    [
      RS.AirshipTerminal.Airship
      C1.Actors.Alex if @state 'alexPresent'
    ]

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode0/chapter1/sections/airship/scenes/dock.script'

  initializeScript: ->
    terminal = @options.parent

    @setThings {terminal}

    @setCallbacks
      BoardAirship: (complete) ->
        LOI.adventure.goToLocation RS.AirshipTerminal.Airship.Cabin

        complete()

  onEnter: (enterResponse) ->
    ephemeralState = @script.ephemeralState()

    hadDrink = false
    bottles = PAA.Items.Bottle.getCopies timelineId: PAA.TimelineIds.DareToDream

    # Return first bottle we find.
    if bottles.length
      hadDrink = bottles[0].state 'lastDrinkTime'

    ephemeralState.hadDrink = hadDrink

    @startScript()
