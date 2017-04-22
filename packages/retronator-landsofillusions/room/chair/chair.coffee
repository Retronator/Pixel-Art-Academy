LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

class HQ.LandsOfIllusions.Room.Chair extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.LandsOfIllusions.Room.Chair'
  @url: -> 'retronator/landsofillusions/room/chair'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @fullName: -> "virtual reality chair"

  @shortName: -> "chair"

  @description: ->
    "
      It's a comfortable looking recliner that will take you to Lands of Illusions.
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
