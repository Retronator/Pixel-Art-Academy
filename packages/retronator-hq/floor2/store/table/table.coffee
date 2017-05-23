LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy
Blog = Retronator.Blog

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Store.Table'
  @url: -> 'retronator/store/table'
  @region: -> HQ

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @fullName: -> "Retro's table"
  @shortName: -> "table"
  @descriptiveName: -> "A ![table](look at table) full of the latest photos and papers."
  @description: ->
    "
      The big store desk is filled with the latest things Retro came across while living his digital life.
    "

  @initialize()

  @showPost: (post) ->
    @state 'activePostId', post._id

  constructor: ->
    super
    
    @postsSkip = new ReactiveField 0

    retro = HQ.Actors.Retro.createAvatar()

    @autorun (computation) =>
      activePostId = @state 'activePostId'
      
      if activePostId
        Blog.Post.forId.subscribe activePostId

      else
        Blog.Post.all.subscribe 5, @postsSkip()
      
    # Dynamically create the 5 things on the table.
    @_things = new ComputedField =>
      activePostId = @state 'activePostId'

      for post in Blog.Post.documents.find(activePostId or {}, sort: time: -1).fetch()
        itemOptions =
          post: post

        if activePostId
          _.extend itemOptions,
            retro: retro
            table: @
            interactions: true

        @constructor.Item.createItem itemOptions

    @currentInteraction = new ReactiveField null

    @autorun (computation) =>
      return unless activePostId = @state 'activePostId'
      return unless item = @_things()?[0]
      return unless item.post._id is activePostId
      return if item.started()

      # We made the item for the current active post.
      item.start()

  startInteraction: (interaction) ->
    @currentInteraction interaction

  illustrationHeight: ->
    @currentInteraction()?.illustrationHeight() or 0

  things: ->
    things = @_things()

    _.flattenDeep [
      things
    ]

  exits: ->
    activePostId = @state 'activePostId'

    if activePostId
      "#{Vocabulary.Keys.Directions.In}": HQ.Store.Table
      "#{Vocabulary.Keys.Directions.Out}": HQ.Store

    else
      "#{Vocabulary.Keys.Directions.Back}": HQ.Store

  # Listener

  onExitAttempt: (exitResponse) ->
    table = @options.parent

    # On exit, clear active post.
    table.state 'activePostId', null

    # If we're just returning back to table, reset the interface since the location won't really change.
    if exitResponse.destinationLocationClass is HQ.Store.Table
      LOI.adventure.interface.resetInterface?()
