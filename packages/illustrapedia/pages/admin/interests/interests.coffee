AM = Artificial.Mummification
IL = Illustrapedia

class IL.Pages.Admin.Interests extends Artificial.Mummification.Admin.Components.AdminPage
  @register 'Illustrapedia.Pages.Admin.Interests'

  constructor: ->
    super
      documentClass: IL.Interest
      adminComponentClass: @constructor.Interest
      nameField: 'name'
      singularName: 'interest'
      pluralName: 'interests'
