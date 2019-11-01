LOI = LandsOfIllusions

class Retronator.HQ extends LOI.Adventure.Region
  @id: -> 'Retronator.HQ'
  @debug = false

  @initialize()

  @scenes: -> [
    @Scenes.Intercom
    @Scenes.Shelley
    @Scenes.Inventory
  ]

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_retronator-hq'
    assets: Assets

  # Export assets in the retronator folder. We do it here instead of the retronator package since that
  # would cause a circular dependency as retronator is a top-level package imported before landsofillusions.
  LOI.Assets.addToExport 'retronator'
