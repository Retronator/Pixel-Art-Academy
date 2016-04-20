PAA = PixelArtAcademy

class PAA.Adventure.Item
  @activatedState:
    Deactivated: 'Deactivated'
    Activating: 'Activating'
    Activated: 'Activated'
    Deactivating: 'Deactivating'

  # The unique name that is used to identify the item in code and in urls
  keyName: -> throw new Meteor.Error 'unimplemented', "You must specify item's key name."

  # The name that appears as the item's description.
  displayName: -> throw new Meteor.Error 'unimplemented', "You must specify item's display name."

  # Tells if the item supports the activate interaction.
  isActivatable: -> false
  activateVerbs: -> throw new Meteor.Error 'unimplemented', "You must specify the verbs that trigger activation."
  deactivateVerbs: -> throw new Meteor.Error 'unimplemented', "You must specify the verbs that trigger deactivation."

  constructor: ->
    # An item that can be activated has 4 stages in its lifecycle. You can use this
    # as a reactive variable to depend on the state the item is currently in.
    @activatedState = new ReactiveField @constructor.activatedState.Deactivated

  deactivated: -> @activatedState() is @constructor.activatedState.Deactivated
  activating: -> @activatedState() is @constructor.activatedState.Activating
  activated: -> @activatedState() is @constructor.activatedState.Activated
  deactivating: -> @activatedState() is @constructor.activatedState.Deactivating

  activate: ->
    # The item gets activated (used).
    @activatedState @constructor.activatedState.Activating

    @onActivate =>
      @activatedState @constructor.activatedState.Activated

  deactivate: ->
    # The item gets deactivated.
    @activatedState @constructor.activatedState.Deactivating

    @onDeactivate =>
      @activatedState @constructor.activatedState.Deactivated

  draw: ->
    # Override and return a component if you want the item to provide some sort of UI.
    null

  # Handlers

  onActivate: (finishedActivatingCallback) ->
    # Override to perform any logic when item is activated. Report that you've done the necessary
    # steps by calling the provided callback. By default we just call the callback straight away.
    finishedActivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    # Override to perform any logic when item is about to be deactivated. Report that you've done the
    # necessary steps by calling the provided callback. By default we just call the callback straight away.
    finishedDeactivatingCallback()
