LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Concourse extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Concourse'
  @url: -> 'spaceport/concourse'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "airport terminal concourse"
  @shortName: -> "concourse"
  @description: ->
    "
      The airport terminal is small and cozy with only a few dozen people transferring from airplanes towards
      the arrivals area in the east. Floor-to-ceiling windows on the north
      wall reveal a terrace that overlooks the main island. The escalators in the west lead down to the airport gates.
    "
  
  @initialize()

  constructor: ->
    super
    
    # When the user reaches the concourse, the game is marked as started.
    # TODO: Move this into S01E01 first chapter trigger.
    Tracker.autorun (computation) =>
      return unless gameState = LOI.adventure.gameState()
      computation.stop()

      gameState.gameStarted = true
      LOI.adventure.gameState.updated()

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.North}": RS.AirportTerminal.Terrace
    "#{Vocabulary.Keys.Directions.Out}": RS.AirportTerminal.Terrace
    "#{Vocabulary.Keys.Directions.East}": RS.AirportTerminal.Immigration
    "#{Vocabulary.Keys.Directions.Down}": RS.AirportTerminal.Gates
    "#{Vocabulary.Keys.Directions.West}": RS.AirportTerminal.Gates
