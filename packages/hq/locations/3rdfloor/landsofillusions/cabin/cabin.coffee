LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.LandsOfIllusions.Cabin extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.LandsOfIllusions.Cabin'
  @url: -> 'retronator/landsofillusions/cabin'
  @scriptUrls: -> [
    'retronator_hq/hq.script'
    'retronator_hq/locations/3rdfloor/landsofillusions/cabin/operator.script'
  ]

  @fullName: -> "Lands of Illusions virtual reality cabin"
  @shortName: -> "cabin"
  @description: ->
    "
      You enter a cosy cabin just big enough for a big futuristic reclining chair located in the middle.
      A virtual reality headset is suspended from the ceiling and connected to a computer terminal on the side.
      There is nowhere else to go but out. Or … wait … enter Lands of Illusions!
    "
  
  @initialize()

  constructor: ->
    super

  @initialState: ->
    things = {}

    exits = {}
    exits[Vocabulary.Keys.Directions.Out] = HQ.Locations.LandsOfIllusions.Hallway.id()
    exits[Vocabulary.Keys.Directions.East] = HQ.Locations.LandsOfIllusions.Hallway.id()

    _.merge {}, super,
      things: things
      exits: exits

  onScriptsLoaded: ->
    # Operator
    Tracker.autorun (computation) =>
      return unless state = @state()

      unless state.things[HQ.Actors.Operator.id()]
        # Operator is not at this location so quit.
        computation.stop()
        return

      return unless operator = @things HQ.Actors.Operator.id()
      computation.stop()

      operatorDialog = @scripts['Retronator.HQ.Locations.LandsOfIllusions.Cabin.Scripts.Operator']

      operatorDialog.setActors
        operator: operator

      operatorDialog.setCallbacks
        Move: (complete) =>
          # Operator leaves back to the reception.
          @options.adventure.scriptHelpers.moveThingBetweenLocations
            thing: HQ.Actors.Operator
            sourceLocation: @
            destinationLocation: HQ.Locations.LandsOfIllusions

          complete()

      # Operator starts talking automatically.
      @director().startScript operatorDialog
