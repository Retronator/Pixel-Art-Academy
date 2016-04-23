AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelBoy.OS extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.OS'

  constructor: ->
    super

  onCreated: ->
    super

    $('html').addClass('pixel-art-academy-style-pixelboy-os')

    homescreen = new PAA.PixelBoy.Apps.HomeScreen @

    @apps = [
      new PAA.PixelBoy.Apps.Journal @
      new PAA.PixelBoy.Apps.Calendar @
      new PAA.PixelBoy.Apps.Pico8 @
    ]

    # Create a map for fast retrieval of apps by their url name.
    appsNameMap = _.object ([app.urlName(), app] for app in @apps)
    @appsMap = appsNameMap

    @currentApp = new ReactiveField null #appsNameMap[FlowRouter.getParam 'app']

    @autorun =>
      appUrlName = FlowRouter.getParam 'app'
      Tracker.nonreactive =>
        newApp = appsNameMap[appUrlName] or homescreen
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

    # Create pixel scaling display.
    @display = new Artificial.Mirage.Display
      safeAreaWidth: 320
      safeAreaHeight: 240
      minScale: 2

  onDestroyed: ->
    super

    $('html').removeClass('pixel-art-academy-style-pixelboy-os')
