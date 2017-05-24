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

    # Go to table if needed.
    atTable = LOI.adventure.currentLocation() instanceof HQ.Store.Table
    LOI.adventure.goToLocation HQ.Store.Table unless atTable

    # Reset the interface to force showing the intro text.
    #Tracker.afterFlush =>
      #LOI.adventure.interface.resetInterface()

  constructor: ->
    super
    
    @postsSkip = new ReactiveField 0

    retro = HQ.Actors.Retro.createAvatar()

    @currentInteraction = new ReactiveField null

    @autorun (computation) =>
      activePostId = @state 'activePostId'
      
      if activePostId
        Blog.Post.forId.subscribe activePostId

      else
        @currentInteraction null
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

        @constructor.Item.createItem itemOptions

    @autorun (computation) =>
      return unless activePostId = @state 'activePostId'
      return unless item = @_things()?[0]
      return unless item.post._id is activePostId
      return if item.started()

      # We made the item for the current active post.
      item.start()

  onRendered: ->
    super

    @$uiArea = $('.ui-area')
    @$table = $('.retronator-hq-store-table')

  things: ->
    things = @_things()

    _.flattenDeep [
      things
    ]

  exits: ->
    activePostId = @state 'activePostId'

    if activePostId
      "#{Vocabulary.Keys.Directions.Back}": HQ.Store.Table
      "#{Vocabulary.Keys.Directions.Out}": HQ.Store

    else
      "#{Vocabulary.Keys.Directions.Back}": HQ.Store

  illustrationHeight: ->
    @currentInteraction()?.illustrationHeight() or 0

  description: ->
    # Show the introduction text of the active item.
    if @state 'activePostId'
      item = @_things()?[0]
      return item?.introduction()

    super

  onScroll: ->
    scrollTop = -parseInt $.Velocity.hook(@$uiArea, 'translateY') or 0
    @$table.css transform: "translate3d(0, #{-scrollTop}px, 0)"

  startInteraction: (interaction) ->
    @currentInteraction interaction

  # Listener

  onExitAttempt: (exitResponse) ->
    table = @options.parent

    console.log "Exit", exitResponse

    if exitResponse.currentLocationClass is HQ.Store.Table
      # On exit, clear active post.
      table.state 'activePostId', null

      if exitResponse.destinationLocationClass is HQ.Store.Table
        LOI.adventure.interface.resetInterface
          resetIntroduction: false
