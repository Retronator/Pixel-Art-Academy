LOI = LandsOfIllusions

class SanFrancisco.C3 extends LOI.Adventure.Region
  @id: -> 'SanFrancisco.C3'
  @debug = false

  @initialize()
  
  @playerHasPermission: -> @validateAvatarEditor()
  @exitLocation: -> SanFrancisco.C3.Lobby

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_sanfrancisco-c3'
    assets: Assets
