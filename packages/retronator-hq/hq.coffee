LOI = LandsOfIllusions

class Retronator.HQ
  @debug = false

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_retronator-hq'
    assets: Assets
