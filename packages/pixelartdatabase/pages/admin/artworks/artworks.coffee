AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PADB.Pages.Admin.Artworks extends PAA.Pages.Admin.Components.AdminPage
  @register 'PixelArtDatabase.Pages.Admin.Artworks'

  constructor: ->
    super
      documentClass: PADB.Artwork
      adminComponentClass: @constructor.Artwork
      nameField: 'title'
      singularName: 'artwork'
      pluralName: 'artworks'
