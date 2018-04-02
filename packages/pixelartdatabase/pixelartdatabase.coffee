class PixelArtDatabase
  constructor: ->
    Retronator.App.addAdminPage '/admin/pixelartdatabase', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/pixelartdatabase/scripts', @constructor.Pages.Admin.Scripts
    Retronator.App.addAdminPage '/admin/pixelartdatabase/artists/:documentId?', @constructor.Pages.Admin.Artists
    Retronator.App.addAdminPage '/admin/pixelartdatabase/artworks/:documentId?', @constructor.Pages.Admin.Artworks
    Retronator.App.addAdminPage '/admin/pixelartdatabase/websites/:documentId?', @constructor.Pages.Admin.Websites
    Retronator.App.addAdminPage '/admin/pixelartdatabase/profiles/:documentId?', @constructor.Pages.Admin.Profiles

if Meteor.isClient
  window.PADB = PixelArtDatabase
