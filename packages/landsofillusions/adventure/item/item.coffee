AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure.Item extends LOI.Adventure.Thing
  # Static location properties and methods

  @ActivatedStates:
    Deactivated: 'Deactivated'
    Activating: 'Activating'
    Activated: 'Activated'
    Deactivating: 'Deactivating'

  # Support for items that can be picked up.

  @inInventory: -> @state 'inInventory'

  @unlessInInventory: ->
    if @inInventory() then null else @

  # Items with multiple copies
  
  @createCopy: (options = {}) ->
    copyId = options.id or Random.id()
    copy = @getCopyForId copyId

    copy.state 'timelineId', options.timelineId if options.timelineId

    copy

  @getCopies: (options = {}) ->
    copies = @state 'copies'

    copyInstances = (@getCopyForId copyId for copyId of copies)

    if options.timelineId
      copyInstances = _.filter copyInstances, (copy) -> copy.state('timelineId') is options.timelineId

    copyInstances

  @getCopyForId: (id) ->
    new @
      stateAddress: @stateAddress.child "copies.#{id}"
      copyId: id

  # Item instance

  constructor: (@options) ->
    super arguments...
    
    # An item that can be activated has 4 stages in its lifecycle. You can use this
    # as a reactive variable to depend on the state the item is currently in.
    @activatedState = new ReactiveField @constructor.ActivatedStates.Deactivated

    # Override state address if it was provided (used with copies).
    if @options?.stateAddress
      @stateAddress = @options.stateAddress
      @state = new LOI.StateObject address: @stateAddress

    if @options?.copyId
      @copyId = @options.copyId

      # Also override the _id since it's used as a unique identifier in rendering.
      @_id = @copyId

  deactivated: -> @activatedState() is @constructor.ActivatedStates.Deactivated
  activating: -> @activatedState() is @constructor.ActivatedStates.Activating
  activated: -> @activatedState() is @constructor.ActivatedStates.Activated
  deactivating: -> @activatedState() is @constructor.ActivatedStates.Deactivating

  activate: (onActivatedCallback) ->
    # The item gets activated (used).
    @activatedState @constructor.ActivatedStates.Activating

    @onActivate =>
      @activatedState @constructor.ActivatedStates.Activated
      onActivatedCallback?()

  deactivate: (onDeactivatedCallback) ->
    # The item gets deactivated.
    @activatedState @constructor.ActivatedStates.Deactivating

    @onDeactivate =>
      @activatedState @constructor.ActivatedStates.Deactivated
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
