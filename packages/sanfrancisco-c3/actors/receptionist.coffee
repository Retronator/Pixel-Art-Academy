LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Actors.Receptionist extends LOI.Adventure.Thing
  @id: -> 'SanFrancisco.C3.Actors.Receptionist'
  @fullName: -> "receptionist"
  @description: -> "It's an elderly man with a friendly, wise composure."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.yellow
    shade: LOI.Assets.Palette.Atari2600.characterShades.normal

  @initialize()
