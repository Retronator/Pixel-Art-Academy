LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy
Blog = Retronator.Blog

Vocabulary = LOI.Parser.Vocabulary

class HQ.Store.Table extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Store.Table'
  @url: -> 'retronator/store/table'
  @region: -> HQ

  @version: -> '0.0.1'

  @fullName: -> "Retro's table"
  @shortName: -> "table"
  @descriptiveName: -> "A ![table](look at table) full of the latest photos and papers."
  @description: ->
    "
      The big store desk is filled with the latest things Retro came across while living his digital life.
    "

  @initialize()

  constructor: ->
    super
    
    @postsSkip = new ReactiveField 0

    retro = HQ.Actors.Retro.createAvatar()

    @autorun (computation) =>
      Blog.Post.all.subscribe 5, @postsSkip()
      
    # Dynamically create the 5 things on the table.
    @_things = new ComputedField =>
      for post in Blog.Post.documents.find().fetch()
        @constructor.Item.createItem
          post: post
          retro: retro

  things: ->
    things = @_things()

    _.flattenDeep [
      things
      thing.interactions for thing in things
    ]

  exits: ->
    "#{Vocabulary.Keys.Directions.Back}": HQ.Store
