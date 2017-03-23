LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Elevator extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Elevator'
  @url: -> 'retronator/lobby/elevator'
  @scriptUrls: -> [
    'retronator-hq/hq.script'
    'retronator-hq/locations/elevator/numberpad.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Retronator HQ elevator"
  @shortName: -> "elevator"
  @description: ->
    "
      You are in the elevator of Retronator HQ. The number pad on the side lets you travel to different floors.
    "

  @initialize()

  @floor: ->
    return unless LOI.adventure.gameState()

    floor = @state 'floor'

    # Set floor to 1 by default
    unless floor
      floor = 1
      @state 'floor', floor

    floor

  things: -> [
    HQ.Elevator.NumberPad
  ]

  exits: ->
    # We register dependency on elevator floor.
    floor = @constructor.floor()

    switch floor
      when 1 then exitLocation = HQ.Passage
      when -1 then exitLocation = HQ.Basement

    exits = {}

    if exitLocation
      exits[Vocabulary.Keys.Directions.North] = exitLocation
      exits[Vocabulary.Keys.Directions.Out] = exitLocation

    exits

  @addElevatorExit: (options, exits) ->
    # See if elevator floor is the same as the location floor.
    elevatorFloor = HQ.Elevator.floor()
    locationFloor = options.floor

    return exits unless elevatorFloor is locationFloor

    # Add the south exit to exits.
    _.extend exits,
      "#{Vocabulary.Keys.Directions.South}": HQ.Elevator
