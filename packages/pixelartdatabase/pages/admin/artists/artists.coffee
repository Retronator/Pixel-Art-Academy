AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PADB.Pages.Admin.Artists extends PAA.Pages.Admin.Components.AdminPage
  @register 'PixelArtDatabase.Pages.Admin.Artists'

  constructor: ->
    super
      documentClass: PADB.Artist
      adminComponentClass: @constructor.Artist
      nameField: 'displayName'
      singularName: 'artist'
      pluralName: 'artists'
