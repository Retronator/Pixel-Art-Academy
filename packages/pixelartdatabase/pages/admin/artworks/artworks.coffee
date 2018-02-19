AM = Artificial.Mirage
LOI = LandsOfIllusions
PADB = PixelArtDatabase

class PADB.Pages.Admin.Artworks extends Artificial.Mummification.Admin.Components.AdminPage
  @register 'PixelArtDatabase.Pages.Admin.Artworks'

  constructor: ->
    super
      documentClass: PADB.Artwork
      adminComponentClass: @constructor.Artwork
      nameField: 'title'
      singularName: 'artwork'
      pluralName: 'artworks'
