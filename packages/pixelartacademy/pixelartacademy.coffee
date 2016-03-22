AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

FlowRouter.wait()

class PixelArtAcademy extends Artificial.Base.App
  @register 'PixelArtAcademy'

  constructor: ->
    super

    # Pages
    @_addPage 'home', '/', new @constructor.Pages.Home

    @_addAdminPage 'admin', '/admin', new @constructor.Pages.Admin
    @_addAdminPage 'adminArtists', '/admin/artists/:documentId?', new @constructor.Artworks.Components.Admin.Artists
    @_addAdminPage 'adminArtworks', '/admin/artworks/:documentId?', new @constructor.Artworks.Components.Admin.Artworks

    # Apps
    @_addPage 'calendar', '/calendar', new @constructor.Apps.Calendar

    FlowRouter.initialize()

  _addPage: (name, url, page) ->
    FlowRouter.route url,
      name: name

      triggersEnter: =>
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
