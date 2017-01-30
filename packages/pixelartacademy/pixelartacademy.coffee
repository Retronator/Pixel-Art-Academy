AT = Artificial.Telepathy
AB = Artificial.Base

class PixelArtAcademy
  constructor: ->
    AB.addRoute '/pixelboy/:app?/:path?', PixelArtAcademy.Layouts.AlphaAccess, PixelArtAcademy.PixelBoy

if Meteor.isClient
  window.PAA = PixelArtAcademy
