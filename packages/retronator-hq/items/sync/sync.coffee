LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.Sync extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.Items.Sync'
  @url: -> 'sync'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "SYNC"

  @description: ->
    "
      It's Neurasync's Synchronization Neural Connector, SYNC for short. It looks like a fitness tracker wristband.
    "

  @defaultScriptUrl: -> 'retronator_retronator-hq/items/sync/sync.script'

  @initialize()

  @activateHeadsetCallback: (complete) =>
    sync = LOI.adventure.getCurrentThing HQ.Items.Sync
    sync.activate()

    complete()

  @deactivateHeadsetCallback: (complete) =>
    sync = LOI.adventure.getCurrentThing HQ.Items.Sync
    sync.deactivate()

    complete()

  @plugInCallback: (complete) =>
    # Start Lands of Illusions VR Experience.
    sync = LOI.adventure.getCurrentThing HQ.Items.Sync
    sync.plugIn()

    complete()

  onCreated: ->
    super

    @pluggedIn = new ReactiveField false

  pluggedInClass: ->
    'pluggedIn' if @pluggedIn()

  plugIn: ->
    @pluggedIn true

    Meteor.setTimeout =>
      LOI.adventure.goToLocation LOI.Construct.Loading
      LOI.adventure.goToTimeline PAA.TimelineIds.Construct
      @deactivate()
    ,
      4000

  onActivate: (finishedActivatingCallback) ->
    Meteor.setTimeout =>
      finishedActivatingCallback()
    ,
      500

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  # Script

  initializeScript: ->
    operator = @options.listener.avatars.operator

    @setThings
      operator: operator

    @setCallbacks
      ActivateHeadset: (complete) => HQ.Items.Sync.activateHeadsetCallback complete
      PlugIn: (complete) => HQ.Items.Sync.plugInCallback complete
      DeactivateHeadset: (complete) => HQ.Items.Sync.deactivateHeadsetCallback complete

  # Listener

  @avatars: ->
    operator: HQ.Actors.Operator

  onCommand: (commandResponse) ->
    sync = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.Use, sync.avatar]
      action: => @startScript()
