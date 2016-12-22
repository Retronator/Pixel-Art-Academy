LOI = LandsOfIllusions

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class LOI.Construct.Locations.Loading extends LOI.Adventure.Location
  @id: -> 'LandsOfIllusions.Construct.Locations.Loading'
  @url: -> 'construct'
  @scriptUrls: -> [
    'retronator_construct/locations/loading/captain.script'
  ]

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

    @_operator = new Retronator.HQ.Actors.Operator
      adventure: @options.adventure

    $('body').addClass('construct')

  destroy: ->
    super

    @_operator.destroy()

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
    # Captain
    Tracker.autorun (computation) =>
      return unless captain = @things LOI.Construct.Actors.Captain
      return unless captain.ready()
      return unless @_operator.ready()
      computation.stop()

      captain.addAbility new Action
        verb: Vocabulary.Keys.Verbs.Talk
        action: =>
          @director().startScript captainDialog, label: 'MainDialog'

      captainDialog = @scripts['LandsOfIllusions.Construct.Locations.Loading.Scripts.Captain']

      captainDialog.setActors
        captain: captain
        operator: @_operator

      captainDialog.setCallbacks
        C3: (complete) =>
          LOI.Adventure.goToLocation LOI.Construct.Locations.C3.Entrance
          complete()

        Exit: (complete) =>
          LOI.Adventure.goToLocation Retronator.HQ.Locations.LandsOfIllusions.Room
          complete()

      # Auto-start the captain script.
      @director().startScript captainDialog
