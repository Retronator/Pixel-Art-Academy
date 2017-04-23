LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Items.Intercom extends LOI.Adventure.Thing
  @id: -> 'Retronator.HQ.Items.Intercom'
  @fullName: -> "intercom"
  @description: -> "It's the intercom system at Retronator HQ."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.green
    shade: LOI.Assets.Palette.Atari2600.characterShades.darker

  @dialogDeliveryType: -> LOI.Avatar.DialogDeliveryType.Displaying

  @initialize()
