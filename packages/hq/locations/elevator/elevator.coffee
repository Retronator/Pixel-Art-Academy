LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Elevator extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Elevator'
  @url: -> 'retronator/lobby/elevator'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
    'retronator_hq/locations/elevator/numberpad.script'
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

    @elevatorFloor = new ComputedField =>
      state = @state()
      return unless state

      state.floor

    @autorun (computation) =>
      # We register dependency on elevator floor.
      floor = @elevatorFloor()

      state = Tracker.nonreactive => @state()
      return unless state

      state.exits[Vocabulary.Keys.Directions.West] = null
      state.exits[Vocabulary.Keys.Directions.East] = null

      newFloorId = null

      switch floor
        when 1 then newFloorId = HQ.Locations.Gallery.id()
        when 2 then newFloorId = HQ.Locations.Checkout.id()
        when '3a' then newFloorId = HQ.Locations.LandsOfIllusions.Hallway.id()
        when '3b' then newFloorId = HQ.Locations.IdeaGarden.id()
        when 4 then newFloorId = HQ.Locations.Studio.Hallway.id()

      direction = if floor is '3a' then Vocabulary.Keys.Directions.West else Vocabulary.Keys.Directions.East
      state.exits[direction] = newFloorId
      state.exits[Vocabulary.Keys.Directions.Out] = newFloorId

      Tracker.nonreactive => @options.adventure.gameState.updated()

  @initialState: ->
    things = {}
    things[HQ.Locations.Elevator.NumberPad.id()] = {}

    exits = {}

    _.merge {}, super,
      things: things
      exits: exits
      floor: 1

  @setupElevatorExit: (options) ->
    # The elevator exit should show up when elevator is on the provided floor.
    elevatorPresent = new ComputedField =>
      state = options.location.options.adventure.gameState()
      elevator = state?.locations[HQ.Locations.Elevator.id()]
      return unless elevator

      # HACK: Wait also for the local state to be set, since otherwise the autorun below won't be ready yet.
      return unless options.location.state()

      present = elevator.floor is options.floor

      present

    options.directions ?= [Vocabulary.Keys.Directions.In, Vocabulary.Keys.Directions.West]

    options.location.autorun (computation) =>
      present = elevatorPresent()

      state = Tracker.nonreactive => options.location.state()
      return unless state

      for direction in options.directions
        state.exits[direction] = if present then HQ.Locations.Elevator.id() else null

      Tracker.nonreactive => options.location.options.adventure.gameState.updated()

  onScriptsLoaded: ->
    # Number pad
    Tracker.autorun (computation) =>
      return unless pad = @things HQ.Locations.Elevator.NumberPad.id()
      computation.stop()
  
      pad.addAbility new Action
        verbs: [Vocabulary.Keys.Verbs.Use, Vocabulary.Keys.Verbs.Press]
        action: =>
          @director().startScript padInteraction

      padInteraction = @scripts['Retronator.HQ.Locations.Elevator.Scripts.NumberPad']
  
      padInteraction.setActors
        pad: pad
