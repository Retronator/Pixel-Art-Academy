AM = Artificial.Mirage
LOI = LandsOfIllusions
PADB = PixelArtDatabase

class PADB.Pages.Admin.Profiles extends Artificial.Mummification.Admin.Components.AdminPage
  @register 'PixelArtDatabase.Pages.Admin.Profiles'

  constructor: ->
    super
      documentClass: PADB.Profile
      adminComponentClass: PADB.Pages.Admin.Profiles.Profile
      scriptsComponentClass: PADB.Pages.Admin.Profiles.Scripts
      nameField: 'username'
      singularName: 'profile'
      pluralName: 'profiles'
