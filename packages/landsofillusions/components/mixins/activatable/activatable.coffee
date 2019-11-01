AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Mixins.Activatable extends AM.Component
  @activatedStates:
    Deactivated: 'Deactivated'
    Activating: 'Activating'
    Activated: 'Activated'
    Deactivating: 'Deactivating'

  constructor: ->
    super arguments...

    # An dialog that can be activated has 4 stages in its lifecycle. You can use this
    # as a reactive variable to depend on the state the dialog is currently in.
    @activatedState = new ReactiveField @constructor.activatedStates.Deactivated

  deactivated: -> @activatedState() is @constructor.activatedStates.Deactivated
  activating: -> @activatedState() is @constructor.activatedStates.Activating
  activated: -> @activatedState() is @constructor.activatedStates.Activated
  deactivating: -> @activatedState() is @constructor.activatedStates.Deactivating

  activate: (onActivatedCallback) ->
    return if @activating() or @activated()

    # The dialog gets activated (used).
    @activatedState @constructor.activatedStates.Activating

    @mixinParent().callFirstWith null, 'onActivate', =>
      @activatedState @constructor.activatedStates.Activated
      onActivatedCallback?()

  deactivate: (onDeactivatedCallback) ->
    return if @deactivating() or @deactivated()

    # The dialog gets deactivated.
    @activatedState @constructor.activatedStates.Deactivating

    @mixinParent().callFirstWith null, 'onDeactivate', =>
      @activatedState @constructor.activatedStates.Deactivated
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
