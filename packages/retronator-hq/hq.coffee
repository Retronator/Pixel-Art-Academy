LOI = LandsOfIllusions

class Retronator.HQ extends LOI.Adventure.Region
  @id: -> 'Retronator.HQ'
  @debug = false

  @initialize()

  @scenes: -> [
    @Scenes.Intercom
    @Scenes.Shelley
  ]

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_retronator-hq'
    assets: Assets
