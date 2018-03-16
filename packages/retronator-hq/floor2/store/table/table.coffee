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

  @version: -> '0.0.1'

  @translations: ->
    openedDrawer: "You open a drawer and throw another bunch of things on the table."

  @fullName: -> "Retro's table"
  @shortName: -> "table"
  @descriptiveName: -> "A ![table](look at table) full of the latest photos and papers."
  @description: ->
    "
      The big store desk is filled with the latest things Retro came across while living his digital life.
    "

  description: ->
    return @translations().openedDrawer if @openedDrawer()

    super

  postscript: ->
    if @postsSkip() is 0
      "![Older](look at older) items are stored in the drawers below."

    else
      "![Older](look at older) and ![newer](look at newer) items are stored in the drawers below."


  @initialize()

  constructor: ->
    super
    
    @postsSkip = new ReactiveField 0
    @openedDrawer = new ReactiveField false

    retro = HQ.Actors.Retro.createAvatar()

    @currentInteraction = new ReactiveField null

    @autorun (computation) =>
      Blog.Post.all.subscribe @postsSkip() + 10
      
    # Dynamically create the 5 things on the table.
    @_things = new ComputedField =>
      posts = Blog.Post.documents.find({},
        sort: time: -1
        skip: @postsSkip()
        limit: 5
      ).fetch()

      for post in posts
        itemOptions = {post, retro}

        @constructor.Item.createItem itemOptions

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
    "#{Vocabulary.Keys.Directions.Back}": HQ.Store

  startInteraction: (interaction) ->
    @currentInteraction interaction

  olderItems: -> @_changeItems 5

  newerItems: -> @_changeItems -5

  _changeItems: (delta) ->
    @openedDrawer true
    @postsSkip Math.max 0, @postsSkip() + delta
    LOI.adventure.interface.reset resetIntroduction: false

  # Listener

  @avatars: ->
    olderItems: HQ.Store.Table.OlderItems
    newerItems: HQ.Store.Table.NewerItems

  onEnter: ->
    table = @options.parent

    # Reset opened drawer.
    table.openedDrawer false

  onCommand: (commandResponse) ->
    table = @options.parent

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.LookAt, @avatars.olderItems]
      action: => table.olderItems()
      # We raise the priority so it doesn't collide with '(account) folder'.
      priority: 1

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.LookAt, @avatars.newerItems]
      action: => table.newerItems()

  class @OlderItems extends LOI.Adventure.Thing.Avatar
    @id: -> 'Retronator.HQ.Store.Table.OlderItems'
    @fullName: -> "older items"
    @shortName: -> "older"
    @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
    @initialize @

  class @NewerItems extends LOI.Adventure.Thing.Avatar
    @id: -> 'Retronator.HQ.Store.Table.NewerItems'
    @fullName: -> "newer items"
    @shortName: -> "newer"
    @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
    @initialize @
