AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Item extends LOI.Adventure.Thing
  # Static location properties and methods

  # A map of all item constructors by url and ID.
  @_thingClassesByUrl = {}
  @_thingClassesByID = {}

  @activatedStates:
    Deactivated: 'Deactivated'
    Activating: 'Activating'
    Activated: 'Activated'
    Deactivating: 'Deactivating'

  # Item instance
    
  # Tells if the item supports the activate interaction.
  isActivatable: -> false

  constructor: (@options) ->
    super
    
    # An item that can be activated has 4 stages in its lifecycle. You can use this
    # as a reactive variable to depend on the state the item is currently in.
    @activatedState = new ReactiveField @constructor.activatedStates.Deactivated

  deactivated: -> @activatedState() is @constructor.activatedStates.Deactivated
  activating: -> @activatedState() is @constructor.activatedStates.Activating
  activated: -> @activatedState() is @constructor.activatedStates.Activated
  deactivating: -> @activatedState() is @constructor.activatedStates.Deactivating

  activate: (onActivatedCallback) ->
    # The item gets activated (used).
    @activatedState @constructor.activatedStates.Activating

    @onActivate =>
      @activatedState @constructor.activatedStates.Activated
      onActivatedCallback?()

  deactivate: (onDeactivatedCallback) ->
    # The item gets deactivated.
    @activatedState @constructor.activatedStates.Deactivating

    @onDeactivate =>
      @activatedState @constructor.activatedStates.Deactivated
      onDeactivatedCallback?()

  # Handlers

  onActivate: (finishedActivatingCallback) ->
    # Override to perform any logic when item is activated. Report that you've done the necessary
    # steps by calling the provided callback. By default we just call the callback straight away.
    finishedActivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    # Override to perform any logic when item is about to be deactivated. Report that you've done the
    # necessary steps by calling the provided callback. By default we just call the callback straight away.
    finishedDeactivatingCallback()
