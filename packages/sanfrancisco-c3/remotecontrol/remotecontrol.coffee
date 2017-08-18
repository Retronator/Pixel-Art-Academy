LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.RemoteControl extends LOI.Adventure.Location
  @id: -> 'SanFrancisco.C3.RemoteControl'
  @url: -> 'c3/remote-control'
  @region: -> SanFrancisco.Soma

  @version: -> '0.0.1'

  @fullName: -> "Character Construction Center Remote Control"
  @shortName: -> "remote control"
  @description: ->
    "
      The series of halls ends with a room with multiple reclining stations.
      Some of them have pilots in them, seemingly immovable, but bursting with activity in their minds.
    "

  @defaultScriptUrl: -> 'retronator_sanfrancisco-c3/remotecontrol/remotecontrol.script'

  @initialize()

  things: -> [
    Retronator.HQ.LandsOfIllusions.Room.Chair
  ]

  exits: ->
    "#{Vocabulary.Keys.Directions.West}": C3.Stasis

  # Script

  initializeScript: ->
    listener = @options.listener

    @setThings listener.avatars

    @setCallbacks
      ActivateHeadset: (complete) => Retronator.HQ.Items.Sync.activateHeadsetCallback complete
      PlugIn: (complete) => Retronator.HQ.Items.Sync.plugInCallback complete
      DeactivateHeadset: (complete) => Retronator.HQ.Items.Sync.deactivateHeadsetCallback complete

  # Listener

  @avatars: ->
    operator: Retronator.HQ.Actors.Operator

  onCommand: (commandResponse) ->
    return unless chair = LOI.adventure.getCurrentThing Retronator.HQ.LandsOfIllusions.Room.Chair

    sitInChair = =>
      @startScript label: 'SelfStart'

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.SitIn, Vocabulary.Keys.Verbs.Use], chair.avatar]
      action: => sitInChair()

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.SitDown]
      action: => sitInChair()
