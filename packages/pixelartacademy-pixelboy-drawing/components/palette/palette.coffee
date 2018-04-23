AM = Artificial.Mirage
LOI = LandsOfIllusions

class PixelArtAcademy.PixelBoy.Apps.Drawing.Components.Palette extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Components.Palette'

  constructor: (@options) ->
    super

    @paletteData = new ComputedField =>
      paletteId = @options.paletteId()

      Meteor.subscribe 'palette', paletteId if paletteId

      LOI.Assets.Palette.documents.findOne paletteId
    
    @currentRamp = new ReactiveField 0
    @currentShade = new ReactiveField 0

    @currentColor = new ComputedField =>
      @paletteData()?.ramps[@currentRamp()]?.shades[@currentShade()]
      
  palette: ->
    # Prepare ramps and shades with extra information. First deep copy the data.
    data = @paletteData()
    return unless data

    palette = $.extend true, {}, data

    # Go over all shades of all ramps.
    rampIndex = 0
    for ramp in palette.ramps
      shadeIndex = 0
      for shade in ramp.shades
        # Replace the data in this place with extra information.
        palette.ramps[rampIndex].shades[shadeIndex] =
          ramp: rampIndex
          shade: shadeIndex
          color: THREE.Color.fromObject shade

        shadeIndex++
      rampIndex++

    palette

  colorStyle: ->
    color = @currentData().color

    backgroundColor: "##{color.getHexString()}"

  activeColorClass: ->
    data = @currentData()
    'active' if data.ramp is @currentRamp() and data.shade is @currentShade()

  events: ->
    super.concat
      'click .color': @onClickColor

  onClickColor: ->
    data = @currentData()
    @currentRamp data.ramp
    @currentShade data.shade
