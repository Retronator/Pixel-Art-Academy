AB = Artificial.Base
AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelBoy.OS extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.OS'

  constructor: (@pixelBoy) ->
    super

    @justOS = not @pixelBoy

    homeScreen = new PAA.PixelBoy.Apps.HomeScreen @

    @apps = [
      new PAA.PixelBoy.Apps.Drawing @
      new PAA.PixelBoy.Apps.Journal @
      new PAA.PixelBoy.Apps.Calendar @
      new PAA.PixelBoy.Apps.Pico8 @
      new PAA.PixelBoy.Apps.JournalScene @
    ]

    # Create a map for fast retrieval of apps by their url name.
    appsNameMap = _.fromPairs ([app.keyName(), app] for app in @apps)
    @appsMap = appsNameMap

    @currentAppKeyName = ComputedField =>
      appKeyName = AB.Router.getParameter('app') or AB.Router.getParameter('parameter2')

      # Make sure this app exists.
      if appsNameMap[appKeyName] then appKeyName else null

    @currentAppPath = ComputedField =>
      AB.Router.getParameter('path') or AB.Router.getParameter('parameter3')

    @currentApp = new ReactiveField null

    # Set currentApp based on url.
    Tracker.autorun (computation) =>
      appKeyName = @currentAppKeyName()

      Tracker.nonreactive =>
        newApp = appsNameMap[appKeyName] or homeScreen
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
      # We show the home screen button if the current app wants it
      # to, but we always hide it when app starts deactivating.
      show = @currentApp().showHomeScreenButton() and not @currentApp().deactivating()

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

    if appKeyName = @currentAppKeyName()
      url = "#{url}/#{appKeyName}"

      if currentAppPath = @currentAppPath()
        url = "#{url}/#{currentAppPath}"

    url

  appPath: (appKeyName, appPath) ->
    appPath = null if appPath instanceof Spacebars.kw

    if @justOS
      AB.Router.createUrl 'pixelBoy',
        app: appKeyName
        path: appPath

    else
      AB.Router.createUrl LOI.adventure,
        parameter1: PAA.PixelBoy.url()
        parameter2: appKeyName
        parameter3: appPath

  go: (appKeyName, appPath) ->
    AB.Router.goToUrl @appPath appKeyName, appPath
