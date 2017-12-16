AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PADB.Pages.Admin.Websites extends PAA.Pages.Admin.Components.AdminPage
  @register 'PixelArtDatabase.Pages.Admin.Websites'

  constructor: ->
    super
      documentClass: PADB.Website
      adminComponentClass: @constructor.Website
      nameField: 'name'
      singularName: 'website'
      pluralName: 'websites'
