LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Elevator extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Elevator'
  @url: -> 'retronator/lobby/elevator'
  @scriptUrls: -> [
    'retronator_hq/locations/elevator/numberpad.script'
  ]

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

      newFloorId = null

      switch floor
        when 1 then newFloorId = HQ.Locations.Lobby.id()
        when 2 then newFloorId = HQ.Locations.Store.id()

      state.exits[Vocabulary.Keys.Directions.Out] = newFloorId
      Tracker.nonreactive => @options.adventure.gameState.updated()

  initialState: ->
    things = {}
    things[HQ.Locations.Elevator.NumberPad.id()] = {}

    exits = {}

    _.merge {}, super,
      things: things
      exits: exits
      floor: 1

  @setupElevatorExit: (options) ->
    # The elevator exit should show up when elevator is on first floor.
    elevatorPresent = new ComputedField =>
      state = options.location.options.adventure.gameState()
      return unless state?.locations[HQ.Locations.Elevator.id()]

      # HACK: Wait also for the local state to be set, since otherwise the next autorun won't be ready yet.
      return unless options.location.state()

      state.locations[HQ.Locations.Elevator.id()].floor is options.floor

    options.location.autorun (computation) =>
      present = elevatorPresent()

      state = Tracker.nonreactive => options.location.state()
      return unless state

      state.exits[Vocabulary.Keys.Directions.In] = if present then HQ.Locations.Elevator.id() else null
      Tracker.nonreactive => options.location.options.adventure.gameState.updated()

  onScriptsLoaded: ->
    # Number pad
    Tracker.autorun (computation) =>
      return unless pad = @things HQ.Locations.Elevator.NumberPad.id()
      computation.stop()
  
      pad.addAbility new Action
        verb: Vocabulary.Keys.Verbs.Use
        action: =>
          @director().startScript padInteraction

      padInteraction = @scripts['Retronator.HQ.Locations.Elevator.Scripts.NumberPad']
  
      padInteraction.setActors
        pad: pad
