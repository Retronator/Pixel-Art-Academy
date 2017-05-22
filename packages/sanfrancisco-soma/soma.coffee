LOI = LandsOfIllusions

class SanFrancisco.Soma extends LOI.Adventure.Region
  @id: -> 'SanFrancisco.Soma'
  @debug = false

  @initialize()

  @scenes: -> [
    @Muni.Scene
  ]

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_sanfrancisco-soma'
    assets: Assets
