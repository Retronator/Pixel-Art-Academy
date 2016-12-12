LOI = LandsOfIllusions

class Retronator.HQ
  @debug = false

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_hq'
    assets: Assets
