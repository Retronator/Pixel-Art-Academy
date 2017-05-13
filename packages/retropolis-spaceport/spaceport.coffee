LOI = LandsOfIllusions

class Retropolis.Spaceport extends LOI.Adventure.Region
  @id: -> 'Retropolis.Spaceport'
  @debug = false

  @initialize()

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_retropolis-spaceport'
    assets: Assets
