LOI = LandsOfIllusions

class Retronator.HQ.Residence extends LOI.Adventure.Region
  @id: -> 'Retronator.HQ.Residence'
  @debug = false

  @initialize()

  @playerHasPermission: -> @validatePatronClubMember()
  @exitLocation: -> Retronator.HQ.ArtStudio
  
if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_retronator-residence'
    assets: Assets
