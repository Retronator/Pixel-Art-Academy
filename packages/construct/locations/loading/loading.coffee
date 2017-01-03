LOI = LandsOfIllusions

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class LOI.Construct.Locations.Loading extends LOI.Construct.Location
  @id: -> 'LandsOfIllusions.Construct.Locations.Loading'
  @url: -> 'construct'
  @scriptUrls: -> super.concat [
    'retronator_construct/locations/loading/captain.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "The Construct loading program"
  @shortName: -> "construct"
  @description: ->
    "
      You find yourself in an open white space, extending into infinity.
      Two red armchairs and an old-fashioned cathode ray tube television are the only items you can see.
    "
  
  @initialize()

  constructor: ->
    super

    $('body').addClass('construct')

  destroy: ->
    super

    $('body').removeClass('construct')

  @initialState: ->
    things = {}
    things[LOI.Construct.Actors.Captain.id()] = {}
    things[LOI.Construct.Locations.Loading.TV.id()] = {}

    exits = {}

    _.merge {}, super,
      things: things
      exits: exits

  onScriptsLoaded: ->
    super

    # Captain
    Tracker.autorun (computation) =>
      return unless captain = @things LOI.Construct.Actors.Captain
      return unless captain.ready()

      return unless operatorLink = @options.adventure.inventory LOI.Construct.Items.OperatorLink
      return unless operatorLink.operator.ready()

      computation.stop()

      captain.addAbility new Action
        verb: Vocabulary.Keys.Verbs.Talk
        action: =>
          @director().startScript captainDialog, label: 'MainDialog'

      captainDialog = @scripts['LandsOfIllusions.Construct.Locations.Loading.Scripts.Captain']

      captainDialog.setActors
        captain: captain
        operator: operatorLink.operator

      captainDialog.setCallbacks
        C3: (complete) =>
          @options.adventure.goToLocation LOI.Construct.Locations.C3.Entrance
          complete()

        Exit: (complete) =>
          @options.adventure.goToLocation Retronator.HQ.Locations.LandsOfIllusions.Room
          complete()

      # Auto-start the captain script.
      @director().startScript captainDialog
