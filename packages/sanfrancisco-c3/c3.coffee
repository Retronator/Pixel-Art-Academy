LOI = LandsOfIllusions

class SanFrancisco.C3 extends LOI.Adventure.Region
  @id: -> 'SanFrancisco.C3'
  @debug = false

  @initialize()
  
  @playerHasPermission: -> @validateAvatarEditor()
  @exitLocation: -> LandsOfIllusions.Construct.Loading
