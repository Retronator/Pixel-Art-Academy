LOI = LandsOfIllusions
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

  activatedClass: ->
    'activated' if (@isRendered() and @activating()) or @activated()

  onActivate: (finishedActivatingCallback) ->
    Meteor.setTimeout =>
      finishedActivatingCallback()
      LOI.adventure.goToLocation LOI.Construct.Locations.Loading
    ,
      4000

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      4000
