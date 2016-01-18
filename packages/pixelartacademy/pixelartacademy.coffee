AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

FlowRouter.wait()

class PixelArtAcademy extends Artificial.Base.App
  @register 'PixelArtAcademy'

  @babelServer = new Artificial.Babel.Server Meteor.settings.public.babelServerUrl

  constructor: ->
    super

    @_addPage 'home', '/', new @constructor.Pages.Home
    @_addPage 'calendar', '/calendar', new @constructor.Apps.Calendar

    FlowRouter.initialize()

  _addPage: (name, url, page) ->
    FlowRouter.route url,
      name: name

      triggersEnter: =>
        @components.add page

      triggersExit: =>
        @components.remove page
