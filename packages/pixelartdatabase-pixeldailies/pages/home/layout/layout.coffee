AM = Artificial.Mirage
PADB = PixelArtDatabase

class PADB.PixelDailies.Pages.Home.Layout extends BlazeComponent
  @register 'PixelArtDatabase.PixelDailies.Pages.Home.Layout'

  @image: (parameters) ->
    Meteor.absoluteUrl "pixelartdatabase/pixeldailies/archive.png"

  onCreated: ->
    super

    @display = new AM.Display
      safeAreaWidth: 350
      safeAreaHeight: 350
      minScale: 2
