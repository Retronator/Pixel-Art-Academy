LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Construct extends LOI.Adventure.Region
  @id: -> 'LandsOfIllusions.Construct'
  @debug = false

  @initialize()

  @playerHasPermission: -> @validatePlayerAccess()
  @exitLocation: -> Retronator.HQ.Basement

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_landsofillusions-construct'
    assets: Assets
