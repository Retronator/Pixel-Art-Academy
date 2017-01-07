LOI = LandsOfIllusions

class Retronator.Studio
  @debug = false

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_retronator_studio'
    assets: Assets
