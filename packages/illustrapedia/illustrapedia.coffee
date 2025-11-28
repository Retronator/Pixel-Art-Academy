class Illustrapedia
  constructor: ->
    Artificial.Pages.addAdminPage '/admin/illustrapedia', @constructor.Pages.Admin
    Artificial.Pages.addAdminPage '/admin/illustrapedia/interests/:documentId?', @constructor.Pages.Admin.Interests

if Meteor.isClient
  window.Illustrapedia = Illustrapedia
