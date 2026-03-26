AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Pages.Admin.Palettes extends Artificial.Mummification.Admin.Components.AdminPage
  @register 'LandsOfIllusions.Assets.Pages.Admin.Palettes'

  constructor: ->
    super
      documentClass: LOI.Assets.Palette
      scriptsComponentClass: LOI.Assets.Pages.Admin.Palettes.Scripts
      adminComponentClass: LOI.Assets.Pages.Admin.Palettes.Palette
      nameField: 'name'
      singularName: 'palette'
      pluralName: 'palettes'
