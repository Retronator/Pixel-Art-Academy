AT = Artificial.Telepathy

class PixelArtAcademy
  constructor: ->
    AT.addRoute 'PixelArtAcademy.PixelBoy', '/pixelboy/:app?/:path?', 'PixelArtAcademy.Layouts.AlphaAccess', 'PixelArtAcademy.PixelBoy'

if Meteor.isClient
  window.PixelArtAcademy = PixelArtAcademy
