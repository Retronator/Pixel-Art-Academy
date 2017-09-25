LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Departures extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Departures'
  @url: -> 'spaceport/departures'
  @region: -> RS

  @version: -> '0.0.1'

  @fullName: -> "airport terminal departures area"
  @shortName: -> "departures"
  @description: ->
    "
      Departures area is a relatively empty corner of the main tower with check-in counters in the south. Once you have
      your ticket ready you can proceed to security in the west.
    "
  
  @initialize()

  constructor: ->
    super

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Northeast}": RS.AirportTerminal.Atrium2ndLevel
    "#{Vocabulary.Keys.Directions.South}": RS.AirportTerminal.CheckIn
    "#{Vocabulary.Keys.Directions.West}": RS.AirportTerminal.Security
