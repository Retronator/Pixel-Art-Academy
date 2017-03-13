LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.AirportTerminal.BaggageClaim extends LOI.Adventure.Location
  @id: -> 'Retropolis.Spaceport.AirportTerminal.BaggageClaim'
  @url: -> 'spaceport/baggage-claim'
  @scriptUrls: -> [
  ]

  @version: -> '0.0.1'

  @fullName: -> "airport terminal baggage claim"
  @shortName: -> "baggage claim"
  @description: ->
    "
      In the baggage claim area, a single carousel is ready to deliver luggage from the next flight.
      You can only continue north to the customs.
    "
  
  @initialize()

  @defaultScriptUrl: -> 'retronator_retropolis-spaceport/airportterminal/arrivals/baggageclaim/baggageclaim.script'

  things: -> [
    @constructor.BaggageCarousel
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.North}": RS.AirportTerminal.Customs
    "#{Vocabulary.Keys.Directions.West}": RS.AirportTerminal.Immigration

  onExitAttempt: (exitResponse) ->
    if exitResponse.destinationLocationClass is RS.AirportTerminal.Immigration
      @startScript label: 'ExitToImmigration'
      exitResponse.preventExit()
