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

  urlName: ->
    throw new Meteor.Error 'unimplemented', "You must specify app's url name."

  constructor: ->
    super
    # An item that can be activated has 4 stages in its lifecycle. You can use this
    # as a reactive variable to depend on the state the item is currently in.
    @activatedState = new ReactiveField @constructor.activatedState.Deactivated

  onRendered: ->
    # if loading the homescreen
    if $('.app-icon').length
      # set up the homescreen loading animations
      loadHomescreen = [
        {
          e: $('.app-wrapper')
          p: 'transition.fadeIn'
        },
        {
          e: $('.app-icon')
          p: 'transition.slideUpIn'
          o: {
            stagger: 150
          }
        }
      ]
      # run animations
      $.Velocity.RunSequence(loadHomescreen);
    #otherwise, just animate in the app
    else
      $('.app-wrapper').velocity('transition.slideUpIn')
      $('.return-to-homescreen').velocity('transition.slideDownIn')

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

    # if on homepage, hide app loader icons before deactivating
    if $('.app-icon').length
      $('.app-icon').velocity 'transition.fadeOut',
        complete: ->
          finishedDeactivatingCallback()
        stagger: 150
    # otherwise, just fade out and finish deactivation
    else
      $('.return-to-homescreen').velocity 'transition.slideUpOut'
      $('.app-wrapper').velocity 'transition.fadeOut',
        complete: ->
          finishedDeactivatingCallback()
