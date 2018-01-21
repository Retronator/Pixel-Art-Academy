AT = Artificial.Telepathy
AB = Artificial.Base

class PixelArtAcademy
  constructor: ->
    AB.Router.addRoute 'pixelart.academy/pixelboy/os/:app?/:path?', @constructor.Layouts.PlayerAccess, @constructor.PixelBoy.OS

    # Create the main adventure engine url capture.
    Retronator.App.addPublicPage 'pixelart.academy/:parameter1?/:parameter2?/:parameter3?/:parameter4?/:parameter5?', @constructor.Adventure

  @TimelineIds:
    # Dream sequence from the intro episode.
    DareToDream: 'DareToDream'

if Meteor.isClient
  window.PixelArtAcademy = PixelArtAcademy
