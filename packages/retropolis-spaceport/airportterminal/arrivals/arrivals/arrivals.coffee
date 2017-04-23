LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.Arrivals extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.Arrivals'
  @url: -> 'spaceport/arrivals'
  @region: -> RS

  @version: -> '0.0.1'

  @fullName: -> "airport terminal arrivals area"
  @shortName: -> "arrivals"
  @description: ->
    "
      You are in the arrivals waiting area of the main spaceport tower. Passengers coming out through customs are being
      greeted by their loved ones. The way out leads south-east to the main atrium.
    "
  
  @initialize()

  @defaultScriptUrl: -> 'retronator_retropolis-spaceport/airportterminal/arrivals/arrivals/arrivals.script'

  things: -> [
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.South}": RS.AirportTerminal.Customs
    "#{Vocabulary.Keys.Directions.Southeast}": RS.Tower.Atrium2ndLevel

  onExitAttempt: (exitResponse) ->
    if exitResponse.destinationLocationClass is RS.AirportTerminal.Customs
      @startScript label: 'ExitToCustoms'
      exitResponse.preventExit()
