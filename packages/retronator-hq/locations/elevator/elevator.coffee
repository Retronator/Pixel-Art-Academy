LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Locations.Elevator extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Elevator'
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

  constructor: ->
    super

    @elevatorFloor = @state.field 'floor', default: 1

  things: ->
    [HQ.Locations.Elevator.NumberPad.id()]

  exits: ->
    # We register dependency on elevator floor.
    floor = @elevatorFloor()

    exits = {}

    newFloorId = null

    switch floor
      when 1 then newFloorId = HQ.Locations.Gallery.id()
      when 2 then newFloorId = HQ.Locations.Checkout.id()
      when '3a' then newFloorId = HQ.Locations.LandsOfIllusions.Hallway.id()
      when '3b' then newFloorId = HQ.Locations.IdeaGarden.id()
      when 4 then newFloorId = HQ.Locations.Studio.Hallway.id()

    direction = if floor is '3a' then Vocabulary.Keys.Directions.West else Vocabulary.Keys.Directions.East

    if newFloorId
      exits[direction] = newFloorId
      exits[Vocabulary.Keys.Directions.Out] = newFloorId

    exits

  @setupElevatorExit: (options) ->
    options.location.elevatorExits = new ReactiveField {}
    
    elevatorFloor = new LOI.StateField
      address: "things.#{HQ.Locations.Elevator.id()}.floor"
      default: 1

    # The elevator exit should show up when elevator is on the provided floor.
    elevatorPresent = new ComputedField =>
      # Do we still need this hack? HACK: Wait also for the local state to be set, since otherwise the autorun below won't be ready yet.
      # return unless options.location.ready()

      elevatorFloor() is options.floor

    options.directions ?= [Vocabulary.Keys.Directions.In, Vocabulary.Keys.Directions.West]

    options.location.autorun (computation) =>
      present = elevatorPresent()
      
      exits = {}

      for direction in options.directions
        state.exits[direction] = if present then HQ.Locations.Elevator.id() else null

      options.location.elevatorExits exits

  onScriptsLoaded: ->
    # Number pad
    Tracker.autorun (computation) =>
      return unless pad = @things HQ.Locations.Elevator.NumberPad.id()
      computation.stop()
  
      pad.addAbility new Action
        verbs: [Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.Press]
        action: =>
          LOI.adventure.director.startScript padInteraction

      padInteraction = @scripts['Retronator.HQ.Locations.Elevator.Scripts.NumberPad']
  
      padInteraction.setThings
        pad: pad
