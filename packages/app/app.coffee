AE = Artificial.Everywhere
AM = Artificial.Mirage
AT = Artificial.Telepathy
LOI = LandsOfIllusions

FlowRouter.wait()

# This is the web app that runs all Retronator websites.
class Retronator.App extends Artificial.Base.App
  @register 'Retronator.App'

  constructor: ->
    super

    # Pages

    @_addPage 'PixelArtAcademy', '/', 'PixelArtAcademy.Pages.Home'

    ###
    @_addAdminPage 'admin', '/admin', new @constructor.Pages.Admin
    @_addAdminPage 'adminArtists', '/admin/artists/:documentId?', new @constructor.Artworks.Components.Admin.Artists
    @_addAdminPage 'adminArtworks', '/admin/artworks/:documentId?', new @constructor.Artworks.Components.Admin.Artworks

    @_addAdminPage 'adminImportCheckIns', '/admin/check-ins/import', new @constructor.Practice.Pages.ImportCheckIns
    @_addAdminPage 'adminExtractImagesFromCheckInPosts', '/admin/check-ins/extract-images-from-posts', new @constructor.Practice.Pages.ExtractImagesFromPosts
    ###

    @_addPage 'LandsOfIllusions.PixelBoy', '/pixelboy/:app?/:path?', 'LandsOfIllusions.PixelBoy'

    # Secondary pages

    new Retronator.Store
    new LOI.Construct

    FlowRouter.initialize()

  _addPage: (name, url, page) ->
    AT.addRoute name, url, 'PixelArtAcademy.Layouts.AlphaAccess', page
