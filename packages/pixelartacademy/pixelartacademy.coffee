AT = Artificial.Telepathy
AB = Artificial.Base

class PixelArtAcademy
  constructor: ->
    AB.Router.addRoute '/pixelboy/:app?/:path?', PixelArtAcademy.Layouts.PlayerAccess, PixelArtAcademy.PixelBoy

  @TimelineIds:
    # Dream sequence from the intro episode.
    DareToDream: 'DareToDream'

    # Playing as yourself.
    RealLife: 'RealLife'

    # Lands of Illusions loading program.
    Construct: 'Construct'

    # Playing as your character in the main (non-time-traveling) game world.
    Present: 'Present'

if Meteor.isClient
  window.PixelArtAcademy = PixelArtAcademy
