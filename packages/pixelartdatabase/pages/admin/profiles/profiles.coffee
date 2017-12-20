AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
PADB = PixelArtDatabase

class PADB.Pages.Admin.Profiles extends PAA.Pages.Admin.Components.AdminPage
  @register 'PixelArtDatabase.Pages.Admin.Profiles'

  constructor: ->
    super
      documentClass: PADB.Profile
      adminComponentClass: @constructor.Profile
      scriptsComponentClass: @constructor.Scripts
      nameField: 'username'
      singularName: 'profile'
      pluralName: 'profiles'
