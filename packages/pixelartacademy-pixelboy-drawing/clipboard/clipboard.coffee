AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PixelArtAcademy.PixelBoy.Apps.Drawing.Clipboard extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Clipboard'
  
  constructor: (@drawing) ->
    super

  activeAssetClass: ->
    'active-asset' if @drawing.portfolio().activeAsset()
