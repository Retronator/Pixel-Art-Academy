LOI = LandsOfIllusions

class Retronator.HQ
  @debug = false

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator-hq'
    assets: Assets
