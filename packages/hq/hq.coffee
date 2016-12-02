LOI = LandsOfIllusions

class Retronator.HQ
  @debug = true

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_hq'
    assets: Assets
