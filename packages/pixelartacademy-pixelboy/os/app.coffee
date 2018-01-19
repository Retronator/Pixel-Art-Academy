AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelBoy.OS.App extends AM.Component
  @activatedState:
    Deactivated: 'Deactivated'
    Activating: 'Activating'
    Activated: 'Activated'
    Deactivating: 'Deactivating'

  displayName: ->
    throw new Meteor.Error 'unimplemented', "You must specify app's display name."

  keyName: ->
    throw new Meteor.Error 'unimplemented', "You must specify app's url name."

  iconName: ->
    @keyName()

  constructor: (@os) ->
    super
    # An item that can be activated has 4 stages in its lifecycle. You can use this
    # as a reactive variable to depend on the state the item is currently in.
    @activatedState = new ReactiveField @constructor.activatedState.Deactivated

    # Does this app lets the device resize?
    @resizable = new ReactiveField true

    # Should the home screen button be shown?
    @showHomeScreenButton = new ReactiveField true

    # The minimum size the device should be let to resize.
    @minWidth = new ReactiveField null
    @minHeight = new ReactiveField null

    # The maximum size the device should be let to resize.
    @maxWidth = new ReactiveField null
    @maxHeight = new ReactiveField null
    
    @useConsoleTheme = false

  onRendered: ->
    super 
    
    $appWrapper = $('.app-wrapper')
    $appWrapper.velocity('transition.slideUpIn', complete: ->
      $appWrapper.css('transform', '')
      console.log "done"
    )

    # Wait for OS to determine its root.
    Tracker.afterFlush =>
      @os.$root.addClass('pixel-art-academy-style-console-app') if @useConsoleTheme
    
  onDestroyed: ->
    super

    @os.$root.removeClass('pixel-art-academy-style-console-app') if @useConsoleTheme

  deactivated: -> @activatedState() is @constructor.activatedState.Deactivated
  activating: -> @activatedState() is @constructor.activatedState.Activating
  activated: -> @activatedState() is @constructor.activatedState.Activated
  deactivating: -> @activatedState() is @constructor.activatedState.Deactivating

  activate: (onActivatedCallback) ->
    # The item gets activated (used).
    @activatedState @constructor.activatedState.Activating

    @onActivate =>
      @activatedState @constructor.activatedState.Activated
      onActivatedCallback?()

  deactivate: (onDeactivatedCallback) ->
    # The item gets deactivated.
    @activatedState @constructor.activatedState.Deactivating

    @onDeactivate =>
      @activatedState @constructor.activatedState.Deactivated
      onDeactivatedCallback?()

  onActivate: (finishedActivatingCallback) ->
    # Override to perform any logic when item is activated. Report that you've done the necessary
    # steps by calling the provided callback. By default we just call the callback straight away.
    finishedActivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    # Override to perform any logic when item is about to be deactivated. Report that you've done the
    # necessary steps by calling the provided callback. By default we just call the callback straight away.

    $('.app-wrapper').velocity 'transition.slideDownOut',
      complete: ->
        finishedDeactivatingCallback()

  setDefaultPixelBoySize: ->
    @minWidth 310
    @minHeight 230

    @maxWidth null
    @maxHeight null

    @resizable true
