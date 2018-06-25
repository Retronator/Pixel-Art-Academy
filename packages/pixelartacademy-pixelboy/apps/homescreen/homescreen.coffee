PAA = PixelArtAcademy
AM = Artificial.Mirage

class PAA.PixelBoy.Apps.HomeScreen extends PAA.PixelBoy.App
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.HomeScreen'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Home screen"
  @description: ->
    "
      It's where you can launch apps on the PixelBoy.
    "

  @initialize()

  template: -> @id()

  constructor: ->
    super
    
    @setMinimumPixelBoySize()

  onRendered: ->
    super
    
    # Run intro animation.
    @$('.pixelartacademy-pixelboy-apps-homescreen').css
      opacity: 1
      
    @$('.apps .app').velocity 'transition.slideUpIn', stagger: 150

  onDeactivate: (finishedDeactivatingCallback) ->
    if $app = @$('.apps .app')
      $app.velocity 'transition.fadeOut',
        complete: ->
          finishedDeactivatingCallback()

        stagger: 150

    else
      finishedDeactivatingCallback()

  apps: ->
    # Show all apps except the home screen.
    _.without @os.currentApps(), @
