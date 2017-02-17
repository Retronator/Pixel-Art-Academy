LOI = LandsOfIllusions
RS = Retropolis.Spaceport

Vocabulary = LOI.Parser.Vocabulary

class RS.Items.Announcer extends LOI.Adventure.Thing
  @id: -> 'Retropolis.Spaceport.Items.Announcer'
  @fullName: -> "announcement system"
  @description: -> "It's the announcement system at Retropolis International Spaceport."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.green
    shade: LOI.Assets.Palette.Atari2600.characterShades.darker

  @dialogDeliveryType: -> LOI.Avatar.DialogDeliveryType.Displaying

  @initialize()
