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

  @initialize()

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
