PAA = PixelArtAcademy
AM = Artificial.Mirage

class PAA.PixelBoy.Apps.HomeScreen extends PAA.PixelBoy.OS.App
  @register 'PixelArtAcademy.PixelBoy.Apps.HomeScreen'

  displayName: ->
    "Home Screen"

  keyName: ->
    'homescreen'
    
  constructor: ->
    super
    
    @setDefaultPixelBoySize()

    @showHomeScreenButton false

  onRendered: ->
    # Run intro animation.
    $('.app-wrapper').css
      display: 'block'
      opacity: 1
      
    $('.app-icon').velocity 'transition.slideUpIn', stagger: 150

  onDeactivate: (finishedDeactivatingCallback) ->
    $('.app-icon').velocity 'transition.fadeOut',
      complete: ->
        finishedDeactivatingCallback()
      stagger: 150

  appKeyName: ->
    app = @currentData()
    app.keyName()

  appDisplayName: ->
    app = @currentData()
    app.displayName()

  appIconName: ->
    app = @currentData()
    app.iconName()
