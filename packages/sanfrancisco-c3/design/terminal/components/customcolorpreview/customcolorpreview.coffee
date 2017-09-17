AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Components.CustomColorPreview extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Components.CustomColorPreview'

  name: ->
    part = @data()
    part.properties.name.options.dataLocation()

  colorStyle: ->
    part = @data()
    colorProperty = part.properties.color

    hue = colorProperty.hue()
    shade = colorProperty.shade()

    palette = LOI.palette()
    color = palette.color hue, shade

    textShade = if shade < 4 then shade + 2 else shade - 2
    textColor = palette.color(hue, textShade)

    color: "##{textColor.getHexString()}"
    backgroundColor: "##{color.getHexString()}"
