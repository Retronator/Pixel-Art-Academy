AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

FlowRouter.wait()

class PixelArtAcademy extends Artificial.Base.App
  @register 'PixelArtAcademy'
  @PATHS_NOT_REQUIRING_LOGIN = ['login']

  constructor: ->
    super

    # Pages
    @_addPage 'home', '/', 'PixelArtAcademy.Pages.Home'
    @_addPage 'login', '/login', 'PixelArtAcademy.Pages.Login'

    @_addAdminPage 'admin', '/admin', 'PixelArtAcademy.Pages.Admin'
    @_addAdminPage 'adminArtists', '/admin/artists/:documentId?', 'PixelArtAcademy.Artworks.Components.Admin.Artists'
    @_addAdminPage 'adminArtworks', '/admin/artworks/:documentId?', 'PixelArtAcademy.Artworks.Components.Admin.Artworks'

    @_addAdminPage 'adminImportCheckIns', '/admin/check-ins/import', 'PixelArtAcademy.Practice.Pages.ImportCheckIns'
    @_addAdminPage 'adminExtractImagesFromCheckInPosts', '/admin/check-ins/extract-images-from-posts', 'PixelArtAcademy.Practice.Pages.ExtractImagesFromPosts'

    @_addPage 'pixelBoy', '/pixelboy/os/:app?/:path?', 'PixelArtAcademy.PixelBoy.OS'
    @_addPage 'adventure', '/:parameter1?/:parameter2?/:parameter3?', 'PixelArtAcademy.Adventure'

    FlowRouter.initialize()

  _addPage: (name, url, page) ->
    @_addRoute name, url, 'PixelArtAcademy.Layouts.AlphaAccess', page

  _addAdminPage: (name, url, page) ->
    @_addRoute name, url, 'PixelArtAcademy.Layouts.AdminAccess', page

  _addRoute: (name, url, layout, page) ->
    FlowRouter.route url,
      name: name
      action: (params, queryParams) ->
        BlazeLayout.render layout,
          page: page
