LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Actors.DrShelley extends LOI.Adventure.Thing
  @id: -> 'SanFrancisco.C3.Actors.DrShelley'
  @fullName: -> "Dr. May Shelley"
  @shortName: -> "Dr. Shelley"
  @description: -> "It's Dr. May Shelley, head of design and manufacturing."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.olive
    shade: LOI.Assets.Palette.Atari2600.characterShades.darker

  @initialize()
