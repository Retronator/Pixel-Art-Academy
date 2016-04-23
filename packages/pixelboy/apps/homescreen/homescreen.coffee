PAA = PixelArtAcademy
AM = Artificial.Mirage

class PAA.PixelBoy.Apps.HomeScreen extends PAA.PixelBoy.OS.App
  @register 'PixelArtAcademy.PixelBoy.Apps.HomeScreen'

  displayName: ->
    "Home Screen"

  urlName: ->
    'homescreen'

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

  appUrlName: ->
    app = @currentData()
    app.urlName()

  appDisplayName: ->
    app = @currentData()
    app.displayName()
