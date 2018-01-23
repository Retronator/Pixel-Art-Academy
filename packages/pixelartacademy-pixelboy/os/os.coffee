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

    @$root = if @justOS then $('html') else @$('.pixelartacademy-pixelboy-os').closest('.os')
    @$root.addClass('pixelartacademy-pixelboy-os-root')

  onDestroyed: ->
    super

    @$root.removeClass('pixelartacademy-pixelboy-os-root')

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

  backButtonCallback: ->
    # We return to main menu.
    if @currentAppPath()
      AB.Router.setParameters parameter3: null

    else if @currentAppUrl()
      AB.Router.setParameters parameter2: null

    else
      # No app is open, we should actually close PixelBoy.
      LOI.adventure.deactivateActiveItem()
      return

    # Instruct the back button to cancel closing (so it doesn't disappear).
    cancel: true
