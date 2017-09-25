LOI = LandsOfIllusions

class Retronator.HQ.IdeaGarden extends LOI.Adventure.Region
  @id: -> 'Retronator.HQ.IdeaGarden'
  @debug = false

  @initialize()

  @playerHasPermission: -> @validateIdeaGardenAccess()
  @exitLocation: -> Retronator.HQ.Basement

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_retronator_ideagarden'
    assets: Assets
