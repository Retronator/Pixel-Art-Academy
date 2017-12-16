class PixelArtDatabase
  constructor: ->
    Retronator.App.addAdminPage '/admin/pixelartdatabase', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/pixelartdatabase/artists/:documentId?', @constructor.Pages.Admin.Artists
    Retronator.App.addAdminPage '/admin/pixelartdatabase/artworks/:documentId?', @constructor.Pages.Admin.Artworks
    Retronator.App.addAdminPage '/admin/pixelartdatabase/websites/:documentId?', @constructor.Pages.Admin.Websites

if Meteor.isClient
  window.PADB = PixelArtDatabase
