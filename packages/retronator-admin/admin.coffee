AM = Artificial.Mirage

class Retronator.Admin extends AM.Component
  @register 'Retronator.Admin'

  @initialize: ->
    Artificial.Pages.addAdminPage '/admin', Retronator.Admin
    Artificial.Pages.addAdminPage '/admin/facts', Retronator.Admin.Facts
