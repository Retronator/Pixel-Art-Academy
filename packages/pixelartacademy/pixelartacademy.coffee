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
    @_addPage 'home', '/', new @constructor.Pages.Home
    @_addPage 'login', '/login', new @constructor.Pages.Login

    @_addAdminPage 'admin', '/admin', new @constructor.Pages.Admin
    @_addAdminPage 'adminArtists', '/admin/artists/:documentId?', new @constructor.Artworks.Components.Admin.Artists
    @_addAdminPage 'adminArtworks', '/admin/artworks/:documentId?', new @constructor.Artworks.Components.Admin.Artworks

    @_addAdminPage 'adminImportCheckIns', '/admin/check-ins/import', new @constructor.Practice.Pages.ImportCheckIns
    @_addAdminPage 'adminExtractImagesFromCheckInPosts', '/admin/check-ins/extract-images-from-posts', new @constructor.Practice.Pages.ExtractImagesFromPosts

    # @_addPage 'pixelBoy', '/pixelboy/os/:app?/:path?', new @constructor.PixelBoy.OS
    FlowRouter.route '/pixelboy/os/:app?/:path?',
      name: 'pixelBoy'
    @components.add new @constructor.PixelBoy.OS
    @_addPage 'adventure', '/:parameter1?/:parameter2?/:parameter3?', new @constructor.Adventure

    FlowRouter.initialize()

  onCreated: ->
    super

    # Define a login redirect so the path will be switched after logging out on any page.
    @autorun =>
      return if FlowRouter.getRouteName() in @constructor.PATHS_NOT_REQUIRING_LOGIN

      FlowRouter.go 'login' unless Meteor.userId() and LOI.characterId()

  _addPage: (name, url, page) ->
    FlowRouter.route url,
      name: name

      triggersEnter: =>
        # Mark that we have actually entered this state, so that we only fire exit trigger when we've actually entered.
        # If urls overlap the exit trigger gets called on these paths as well, so this helps us track that end prevent
        # it.
        page._entered = true

        if FlowRouter.getRouteName() in @constructor.PATHS_NOT_REQUIRING_LOGIN
          @components.add page

        else
          Tracker.autorun (computation) =>
            return if Meteor.loggingIn() or not Roles.subscription.ready()
            computation.stop()

            unless LOI.characterId() and Roles.userIsInRole Meteor.userId(), 'alpha-access'
              FlowRouter.go 'login'
              return

            # HACK: when page is just re-added (when url changes for example) the component would not yet be
            # registered as removed at this point, so we add it in next frame.
            Tracker.afterFlush =>
              @components.add page

      triggersExit: =>
        # Make sure we event entered this page. See comment at triggersEnter for reasoning.
        return unless page._entered

        @components.remove page

  _addAdminPage: (name, url, page) ->
    FlowRouter.route url,
      name: name

      triggersEnter: =>
        Tracker.autorun (computation) =>
          return if Meteor.loggingIn() or not Roles.subscription.ready()
          computation.stop()

          unless Roles.userIsInRole Meteor.userId(), 'admin'
            FlowRouter.go 'home'
            return

          # HACK: when admin page is just re-added (when url changes for example) the component would not yet be
          # registered as removed at this point, so we add it in next frame.
          Tracker.afterFlush =>
            @components.add page

      triggersExit: =>
        @components.remove page

  fontSize: ->
    # We scale all fonts set to their pixel perfect sizes with rems with 10px = 1rem as the base.
    10 * @display.scale()
