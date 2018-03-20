LOI = LandsOfIllusions

class LOI.Items extends LOI.Adventure.Global
  @id: -> 'LandsOfIllusions.Items'

  @scenes: -> [
  ]

  @initialize()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_landsofillusions-items'
    assets: Assets
