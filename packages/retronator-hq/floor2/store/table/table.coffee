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

    @autorun (computation) =>
      Blog.Post.all.subscribe 5, @postsSkip()
      
    # Dynamically create the 5 things on the table.
    @_things = new ComputedField =>
      @constructor.Item.createItem post for post in Blog.Post.documents.find().fetch()

  things: -> @_things()

  exits: ->
    "#{Vocabulary.Keys.Directions.Back}": HQ.Store

  # Listener

  onCommand: (commandResponse) ->
    table = @options.parent

    commandResponse.onPhrase
      form: [[Vocabulary.Keys.Verbs.LookAt, Vocabulary.Keys.Verbs.Use], table.avatar]
      priority: 1
      action: =>
        LOI.adventure.goToLocation table
