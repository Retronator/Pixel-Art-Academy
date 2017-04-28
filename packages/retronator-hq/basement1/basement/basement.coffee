LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Basement extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Basement'
  @url: -> 'retronator/basement'

  @version: -> '0.0.1'

  @fullName: -> "Retronator HQ basement reception"
  @shortName: -> "basement"
  @description: ->
    "
      You exit to the basement with a long hallway connecting to the Lands of Illusions virtual reality center in the 
      east. Big windows along north wall let you see into the Idea Garden where Retro designs new
      features. There is a small reception desk near the entrance.
    "
  
  @initialize()

  @defaultScriptUrl: -> 'retronator_retronator-hq/basement1/basement/basement.script'

  constructor: ->
    super

    # Elevator button
    @elevatorButton = new HQ.Items.ElevatorButton
      location: @
      floor: -1

  things: -> [
    HQ.Actors.Operator
    @elevatorButton
  ]

  exits: ->
    HQ.Elevator.addElevatorExit
      floor: -1
    ,
      "#{Vocabulary.Keys.Directions.Up}": HQ.Coworking
      "#{Vocabulary.Keys.Directions.East}": HQ.LandsOfIllusions

  initializeScript: ->
    @setCurrentThings
      operator: HQ.Actors.Operator

  onCommand: (commandResponse) ->
    return unless operator = LOI.adventure.getCurrentThing HQ.Actors.Operator

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.TalkTo, operator.avatar]
      action: => @startScript label: 'OperatorDialog'
