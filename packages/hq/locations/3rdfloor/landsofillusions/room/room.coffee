LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.LandsOfIllusions.Room extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.LandsOfIllusions.Room'
  @url: -> 'retronator/landsofillusions/room'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
    'retronator_hq/locations/3rdfloor/landsofillusions/room/operator.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Lands of Illusions virtual reality room"
  @shortName: -> "room"
  @description: ->
    "
      You enter a cosy room just big enough for a big futuristic reclining chair located in the middle.
      A virtual reality headset is suspended from the ceiling and connected to a computer terminal on the side.
      There is nowhere else to go but out. Or … wait … enter Lands of Illusions!
    "
  
  @initialize()

  constructor: ->
    super

    # Because the operator can be at this location or in the
    # reception, we need to create him ourselves to assure persistence.
    @_operator = new HQ.Actors.Operator
      adventure: @options.adventure

    Tracker.autorun (computation) =>
      # Provide operator state, either from the reception or from the room.
      reception = @options.adventure.getLocationState HQ.Locations.LandsOfIllusions
      room = @options.adventure.getLocationState HQ.Locations.LandsOfIllusions.Room

      @_operatorInReception = reception?.things[HQ.Actors.Operator.id()]
      @_operatorInRoom = room?.things[HQ.Actors.Operator.id()]

      operatorState = @_operatorInReception or @_operatorInRoom

      @_operator.state operatorState

  destroy: ->
    super

    @_operator.destroy()

  @initialState: ->
    things = {}
    things[HQ.Locations.LandsOfIllusions.Room.Chair.id()] = {}

    exits = {}
    exits[Vocabulary.Keys.Directions.Out] = HQ.Locations.LandsOfIllusions.Hallway.id()
    exits[Vocabulary.Keys.Directions.East] = HQ.Locations.LandsOfIllusions.Hallway.id()

    _.merge {}, super,
      things: things
      exits: exits

  onScriptsLoaded: ->
    # Operator

    operatorDialog = @scripts['Retronator.HQ.Locations.LandsOfIllusions.Room.Scripts.Operator']

    operatorDialog.setActors
      operator: @_operator

    operatorDialog.setCallbacks
      WaitToSeat: (complete) =>
        @_waitToSeatComplete = complete

      Move: (complete) =>
        # Operator leaves back to the reception.
        @options.adventure.scriptHelpers.moveThingBetweenLocations
          thing: HQ.Actors.Operator
          sourceLocation: @
          destinationLocation: HQ.Locations.LandsOfIllusions

        complete()

      PlugIn: (complete) =>
        # Add the Construct operator to inventory to enable talking to the operator.
        @options.adventure.scriptHelpers.addItemToInventory item: LOI.Construct.Items.OperatorLink

        # Start Lands of Illusions VR Experience.
        LOI.Adventure.goToItem HQ.Locations.LandsOfIllusions.Room.Chair

        complete()

    # Operator starts talking automatically if he's in the room.
    Tracker.autorun (computation) =>
      # Wait for state to become available.
      return unless @options.adventure.gameState()
      return unless @_operatorInRoom or @_operatorInReception
      computation.stop()

      if @_operatorInRoom
        Tracker.autorun (computation) =>
          return unless @_operator.ready()
          computation.stop()

          @director().startScript operatorDialog

    # Chair
    Tracker.autorun (computation) =>
      return unless chair = @things HQ.Locations.LandsOfIllusions.Room.Chair.id()
      computation.stop()

      chair.addAbility new Action
        verb: Vocabulary.Keys.Verbs.Sit
        action: =>
          # If we're in the middle of the operator script, just continue on sit down.
          return @_waitToSeatComplete() if @_waitToSeatComplete

          # Otherwise start the self-start plug-in script.
          @director().startScript operatorDialog, label: 'SelfStart'
