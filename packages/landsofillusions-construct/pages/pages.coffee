LOI = LandsOfIllusions

class LOI.Construct.Pages
  constructor: ->
    Retronator.App.addAdminPage '/admin/construct', @constructor.Admin
    Retronator.App.addAdminPage '/admin/construct/pre-made-characters', @constructor.Admin.PreMadeCharacters
