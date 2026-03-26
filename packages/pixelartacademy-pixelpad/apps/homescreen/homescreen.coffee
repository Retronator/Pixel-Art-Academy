AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
PAA = PixelArtAcademy

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
  
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    # Allow for the launch sound to play out.
    unloadDelay: 1.7
    variables:
      appHover: AEc.ValueTypes.Boolean
      appLaunch: AEc.ValueTypes.Trigger
      appPan: AEc.ValueTypes.Number
      
  template: -> @id()

  constructor: ->
    super arguments...
    
    @setMinimumPixelPadSize()
    
  onCreated: ->
    super arguments...
    
    $(document).on 'visibilitychange.pixelartacademy-pixelpad-apps-homescreen', =>
      @audio.appHover false if document.visibilityState is 'hidden'

  onRendered: ->
    super arguments...
    
    # Run intro animation.
    @$('.pixelartacademy-pixelpad-apps-homescreen').css
      opacity: 1
      
    @$('.apps .app').velocity 'transition.slideUpIn', stagger: 150
    
  onDestroyed: ->
    super arguments...
    
    $(document).off '.pixelartacademy-pixelpad-apps-homescreen'

  onDeactivate: (finishedDeactivatingCallback) ->
    @audio.appHover false
    
    if $app = @$('.apps .app')
      $app.velocity 'transition.fadeOut',
        complete: ->
          finishedDeactivatingCallback()

        stagger: 150

    else
      finishedDeactivatingCallback()

  allowsShortcutsTable: -> true
  
  enabledClass: ->
    # Note: We have to check the URL since the app itself won't change until the transition.
    'enabled' unless @os.currentAppUrl()

  apps: ->
    # Show all apps except the home screen.
    _.without @os.currentApps(), @

  events: ->
    super(arguments...).concat
      'mouseenter .apps .app': @onMouseEnterApp
      'mouseleave .apps .app': @onMouseLeaveApp
      'click .apps .app .link': @onClickLink
  
  onMouseEnterApp: (event) ->
    @audio.appPan AEc.getPanForElement event.target
    @audio.appHover true
    
  onMouseLeaveApp: (event) ->
    @audio.appHover false
    
  onClickLink: (event) ->
    @audio.appHover false
    @audio.appLaunch()
