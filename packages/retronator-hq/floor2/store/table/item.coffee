LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table.Item extends LOI.Adventure.Item
  @_constructors: ->
    photo: @Photos

  @createItem: (post) ->
    constructor = @_constructors()[post.type] or @Photos

    new constructor {post}

  constructor: (@options) ->
    super @options

    @post = @options.post

    # We need to provide our own ID since multiple instances of this item will appear.
    @_id = Random.id()

  id: ->
    @_id

  onScriptsLoaded: ->
    super

    # We need to manually set the default script since we changed the ID and the default handler won't find it.
    @script = @scripts[@options.parent.constructor.id()]

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      500

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
