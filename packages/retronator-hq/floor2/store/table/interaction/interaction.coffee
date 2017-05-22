AE = Artificial.Everywhere
LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Interaction extends LOI.Adventure.Item
  @fullName: ->
    # An interaction doesn't need a name.
    ''

  isVisible: -> false

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

  start: (@startOptions) ->
    throw new AE.NotImplementedException "Interaction should start the script."

  # A variant of item interaction helper that directly activates an item instead of going through adventure.
  interact: (callback) ->
    # Wait until item has been active and deactivated again.
    itemWasActive = false
    @activate()

    Tracker.autorun (computation) =>
      if @activated() and not itemWasActive
        itemWasActive = true

      else if @deactivated() and itemWasActive
        computation.stop()
        callback()

  provideCallbacks: ->
    # Override to provide any custom callbacks in the interaction's script.
    {}

  # Script

  initializeScript: ->
    item = @options.parent

    callbacks = item.provideCallbacks()

    # When this interaction is over, start the next one.
    callbacks.End = (complete) =>
      LOI.adventure.director.startNode item.startOptions.endNode
      complete()

    @setCallbacks callbacks
