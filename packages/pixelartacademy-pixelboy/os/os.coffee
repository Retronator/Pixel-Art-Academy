AB = Artificial.Base
AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelBoy.OS extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.OS'

  constructor: (@pixelBoy) ->
    super

    @justOS = not @pixelBoy

    @appsLocation = new PAA.PixelBoy.Apps

    @currentAppsSituation = new ComputedField =>
      options =
        timelineId: LOI.adventure.currentTimelineId()
        location: @appsLocation

      return unless options.timelineId and options.location

      new LOI.Adventure.Situation options

    # We use caches to avoid reconstruction.
    @_apps = {}

    # Instantiates and returns all apps that are available to listen to commands.
    @currentApps = new ComputedField =>
      return unless currentAppsSituation = @currentAppsSituation()

      appClasses = currentAppsSituation.things()

      for appClass in appClasses
        # We create the instance in a non-reactive context so that
        # reruns of this autorun don't invalidate instance's autoruns.
        Tracker.nonreactive =>
          @_apps[appClass.id()] ?= new appClass @

        @_apps[appClass.id()]
        
    @currentAppUrl = ComputedField =>
      appUrl = AB.Router.getParameter('app') or AB.Router.getParameter('parameter2')
      appClass = PAA.PixelBoy.App.getClassForUrl appUrl

      # Make sure this app exists.
      if appClass then appUrl else null

    @currentAppPath = ComputedField =>
      AB.Router.getParameter('path') or AB.Router.getParameter('parameter3')

    @currentApp = new ReactiveField null

    # Set currentApp based on url.
    Tracker.autorun (computation) =>
      appUrl = @currentAppUrl()
      appClass = PAA.PixelBoy.App.getClassForUrl(appUrl) or PAA.PixelBoy.Apps.HomeScreen

      Tracker.nonreactive =>
        newApp = _.find @currentApps(), (app) => app instanceof appClass
        currentApp = @currentApp()

        return if newApp is currentApp

        startNewApp = =>
          return unless newApp

          @currentApp newApp
          newApp.activate()

        if currentApp
          currentApp.deactivate =>
            startNewApp()

        else
          startNewApp()

    if @justOS
      # Create pixel scaling display.
      @display = new Artificial.Mirage.Display
        safeAreaWidth: 320
        safeAreaHeight: 240
        minScale: 2

    else
      # Just take adventure's display.
      @display = LOI.adventure.interface.display

  onRendered: ->
    super

    @$root = if @justOS then $('html') else @$('.pixelboy-os').closest('.os')
    @$root.addClass('pixel-art-academy-style-pixelboy-os')

    # Animate home screen button.
    @autorun =>
      return unless currentApp = @currentApp()

      # We show the home screen button if the current app wants it
      # to, but we always hide it when app starts deactivating.
      show = currentApp.showHomeScreenButton() and not currentApp.deactivating()

      # Trigger velocity animation on change.
      if show and not @_homeScreenButtonShown
        Tracker.afterFlush =>
          $('.homescreen-button-area').velocity('transition.slideDownIn')

      else if not show and @_homeScreenButtonShown
        $('.homescreen-button-area').velocity('transition.slideUpOut')

      @_homeScreenButtonShown = show

  onDestroyed: ->
    super

    @$root.removeClass('pixel-art-academy-style-pixelboy-os')

  url: ->
    url = PAA.PixelBoy.url()

    if appUrl = @currentAppUrl()
      url = "#{url}/#{appUrl}"

      if currentAppPath = @currentAppPath()
        url = "#{url}/#{currentAppPath}"

    url

  appPath: (appUrl, appPath) ->
    appPath = null if appPath instanceof Spacebars.kw

    if @justOS
      AB.Router.createUrl 'pixelBoy',
        app: appUrl
        path: appPath

    else
      AB.Router.createUrl LOI.adventure,
        parameter1: PAA.PixelBoy.url()
        parameter2: appUrl
        parameter3: appPath

  go: (appUrl, appPath) ->
    AB.Router.goToUrl @appPath appUrl, appPath
