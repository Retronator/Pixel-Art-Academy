AM = Artificial.Mirage
LOI = LandsOfIllusions
PADB = PixelArtDatabase

class PADB.Pages.Admin.Websites extends Artificial.Mummification.Admin.Components.AdminPage
  @register 'PixelArtDatabase.Pages.Admin.Websites'

  constructor: ->
    super
      documentClass: PADB.Website
      adminComponentClass: PADB.Pages.Admin.Websites.Website
      nameField: 'name'
      singularName: 'website'
      pluralName: 'websites'
