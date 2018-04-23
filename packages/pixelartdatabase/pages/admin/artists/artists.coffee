AM = Artificial.Mirage
LOI = LandsOfIllusions
PADB = PixelArtDatabase

class PADB.Pages.Admin.Artists extends Artificial.Mummification.Admin.Components.AdminPage
  @register 'PixelArtDatabase.Pages.Admin.Artists'

  constructor: ->
    super
      documentClass: PADB.Artist
      adminComponentClass: @constructor.Artist
      nameField: 'displayName'
      singularName: 'artist'
      pluralName: 'artists'
