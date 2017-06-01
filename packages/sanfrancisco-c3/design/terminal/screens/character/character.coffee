AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Character extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Character'

  constructor: (@terminal) ->
    @characterId = new ReactiveField null
    
    @character = new ComputedField =>
      characterId = @characterId()
      
      Tracker.nonreactive =>
        instance = new LOI.Character.Instance characterId
        console.log instance
        instance

  setCharacterId: (characterId) ->
    @characterId characterId
