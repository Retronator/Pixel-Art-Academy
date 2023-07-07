PAA = PixelArtAcademy
AM = Artificial.Mirage

class PAA.PixelPad.Apps.HomeScreen extends PAA.PixelPad.App
  @id: -> 'PixelArtAcademy.PixelPad.Apps.HomeScreen'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Home screen"
  @description: ->
    "
      It's where you can launch apps on the PixelPad.
    "

  @initialize()

  template: -> @id()

  constructor: ->
    super arguments...
    
    @setMinimumPixelPadSize()

  onRendered: ->
    super arguments...
    
    # Run intro animation.
    @$('.pixelartacademy-pixelpad-apps-homescreen').css
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

  allowsShortcutsTable: -> true

  apps: ->
    # Show all apps except the home screen.
    _.without @os.currentApps(), @
