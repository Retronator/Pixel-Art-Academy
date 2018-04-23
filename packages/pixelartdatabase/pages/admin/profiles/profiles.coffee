AM = Artificial.Mirage
LOI = LandsOfIllusions
PADB = PixelArtDatabase

class PADB.Pages.Admin.Profiles extends Artificial.Mummification.Admin.Components.AdminPage
  @register 'PixelArtDatabase.Pages.Admin.Profiles'

  constructor: ->
    super
      documentClass: PADB.Profile
      adminComponentClass: @constructor.Profile
      scriptsComponentClass: @constructor.Scripts
      nameField: 'username'
      singularName: 'profile'
      pluralName: 'profiles'
