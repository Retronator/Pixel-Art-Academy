LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode0.Chapter1
RS = Retropolis.Spaceport

class C1.Start extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1.Start'

  @scenes: -> [
    @Terrace
  ]

  @finished: ->
    # Start section is over when the player has left the terrace. Make sure we don't return undefined though.
    @state('leftTerrace') is true
    
  @listeners: -> [
    @Listener
  ]

  @initialize()

  class @Listener extends LOI.Adventure.Listener
    onExit: (exitResponse) ->
      return unless exitResponse.currentLocationClass is RS.AirportTerminal.Terrace
      super

      # Mark the goal condition when the player exits the terrace.
      @options.parent.state 'leftTerrace', true

      # Set the whole game as started.
      gameState = LOI.adventure.gameState()
      gameState.gameStarted = true
      LOI.adventure.gameState.updated()
