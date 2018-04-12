AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends LOI.Adventure
  _initializeGroups: ->
    # Subscribe to character's groups.
    @autorun (computation) =>
      return unless characterId = LOI.characterId()

      LOI.Character.Group.forCharacterId.subscribe characterId
