LOI = LandsOfIllusions

class LOI.Construct.Pages
  constructor: ->
    Retronator.App.addAdminPage '/admin/construct', @constructor.Admin
