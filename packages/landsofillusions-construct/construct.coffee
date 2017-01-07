LOI = LandsOfIllusions
RA = Retronator.Accounts

class LOI.Construct
  @debug = true

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_construct'
    assets: Assets
