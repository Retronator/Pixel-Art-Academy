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

  constructor: (@os) ->
    super
    # An item that can be activated has 4 stages in its lifecycle. You can use this
    # as a reactive variable to depend on the state the item is currently in.
    @activatedState = new ReactiveField @constructor.activatedState.Deactivated

  onRendered: ->
    $appWrapper = $('.app-wrapper')
    $appWrapper.velocity('transition.slideUpIn', complete: -> $appWrapper.css('transform', ''))
    $('.homescreen-button-area').velocity('transition.slideDownIn')

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

    $('.homescreen-button-area').velocity 'transition.slideUpOut'
    $('.app-wrapper').velocity 'transition.slideDownOut',
      complete: ->
        finishedDeactivatingCallback()
