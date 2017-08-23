LOI = LandsOfIllusions

class SanFrancisco.Apartment extends LOI.Adventure.Region
  @id: -> 'SanFrancisco.Apartment'
  @debug = false

  @initialize()

  @playerHasPermission: ->
    # This region is only accessible to characters, but make sure to
    # return false since undefined would mean we can't determine it.
    LOI.characterId() or false
    
  @exitLocation: -> SanFrancisco.Soma.ChinaBasinPark

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_sanfrancisco-apartment'
    assets: Assets
