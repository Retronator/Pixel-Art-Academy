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

    @_addAdminPage 'admin', '/admin/import-check-ins', new @constructor.Practice.Pages.ImportCheckIns

    @_addPage 'pixelboy', '/pixelboy/:app?', new @constructor.PixelBoy

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
