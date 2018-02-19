class Illustrapedia
  constructor: ->
    Retronator.App.addAdminPage '/admin/illustrapedia', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/illustrapedia/interests/:documentId?', @constructor.Pages.Admin.Interests

if Meteor.isClient
  window.Illustrapedia = Illustrapedia
