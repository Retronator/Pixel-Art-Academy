LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.LandsOfIllusions.Room.Chair extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.LandsOfIllusions.Room.Chair'
  @url: -> 'retronator/landsofillusions/room/chair'

  @version: -> '0.0.1'

  @fullName: -> "recliner chair"

  @shortName: -> "chair"

  @description: ->
    "
      It's a comfortable looking recliner you can use while you're in immersion.
    "

  @initialize()
