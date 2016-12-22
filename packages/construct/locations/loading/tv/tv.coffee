AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ
RA = Retronator.Accounts
RS = Retronator.Store

class LOI.Construct.Locations.Loading.TV extends LOI.Adventure.Item
  @id: -> 'LandsOfIllusions.Construct.Locations.Loading.TV'
  @url: -> 'character-selection'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Television"

  @shortName: -> "TV"

  @description: ->
    "
      It's an old school television with a remote display. There are people's portraits displayed on the screen.
    "

  @initialize()

  constructor: ->
    super

    @addAbilityToActivateByLooking()
