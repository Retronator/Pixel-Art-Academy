LOI = LandsOfIllusions
RS = Retropolis.Spaceport

class RS.AirshipTerminal.Airship.Cabin.TableDisplay extends LOI.Adventure.Thing
  @id: -> 'Retropolis.Spaceport.AirshipTerminal.Airship.Cabin.TableDisplay'
  @fullName: -> "table display"
  @shortName: -> "table"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: -> "It's a table with a built-in informational display."
  @color: ->
    hue: LOI.Assets.Palette.Atari2600.hues.aqua
    shade: LOI.Assets.Palette.Atari2600.characterShades.darkest

  @dialogDeliveryType: -> LOI.Avatar.DialogDeliveryType.Displaying

  @initialize()
