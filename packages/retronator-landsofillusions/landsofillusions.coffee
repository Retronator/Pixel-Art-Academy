LOI = LandsOfIllusions

class Retronator.HQ.LandsOfIllusions extends LOI.Adventure.Region
  @id: -> 'Retronator.HQ.LandsOfIllusions'
  @debug = false

  @initialize()

  @playerHasPermission: -> @validatePlayerAccess()
  @exitLocation: -> Retronator.HQ.Basement
  
if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_retronator-landsofillusions'
    assets: Assets
