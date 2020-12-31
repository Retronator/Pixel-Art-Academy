AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Mixins.Activatable extends AM.Component
  @ActivatedStates:
    Deactivated: 'Deactivated'
    Activating: 'Activating'
    Activated: 'Activated'
    Deactivating: 'Deactivating'

  constructor: ->
    super arguments...

    # An dialog that can be activated has 4 stages in its lifecycle. You can use this
    # as a reactive variable to depend on the state the dialog is currently in.
    @activatedState = new ReactiveField @constructor.ActivatedStates.Deactivated

  deactivated: -> @activatedState() is @constructor.ActivatedStates.Deactivated
  activating: -> @activatedState() is @constructor.ActivatedStates.Activating
  activated: -> @activatedState() is @constructor.ActivatedStates.Activated
  deactivating: -> @activatedState() is @constructor.ActivatedStates.Deactivating

  activate: (onActivatedCallback) ->
    return if @activating() or @activated()

    # The dialog gets activated (used).
    @activatedState @constructor.ActivatedStates.Activating

    @mixinParent().callFirstWith null, 'onActivate', =>
      @activatedState @constructor.ActivatedStates.Activated
      onActivatedCallback?()

  deactivate: (onDeactivatedCallback) ->
    return if @deactivating() or @deactivated()

    # The dialog gets deactivated.
    @activatedState @constructor.ActivatedStates.Deactivating

    @mixinParent().callFirstWith null, 'onDeactivate', =>
      @activatedState @constructor.ActivatedStates.Deactivated
      onDeactivatedCallback?()

  # Handlers

  onActivate: (finishedActivatingCallback) ->
    # Override to perform any logic when dialog is activated. Report that you've done the necessary
    # steps by calling the provided callback. By default we just call the callback straight away.
    finishedActivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    # Override to perform any logic when dialog is about to be deactivated. Report that you've done the
    # necessary steps by calling the provided callback. By default we just call the callback straight away.
    finishedDeactivatingCallback()
