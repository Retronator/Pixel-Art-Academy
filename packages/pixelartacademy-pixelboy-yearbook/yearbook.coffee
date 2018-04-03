AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Yearbook extends PAA.PixelBoy.App
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Yearbook'
  @url: -> 'yearbook'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Yearbook"
  @description: ->
    "
      Learn about your classmates at the Academy.
    "

  @initialize()

  # Subscriptions

  @classOf2016: new AB.Subscription name: "#{@id()}.classOf2016"
  @classOf2016CharactersCollectionName: "#{@id()}.classOf2016Characters"

  if Meteor.isClient
    Yearbook = @

    class @ClassOf2016Character extends LOI.Character
      @id: -> 'PixelArtAcademy.PixelBoy.Apps.Yearbook.Middle.ClassOf2016Character'

      @Meta
        name: @id()
        collection: new Meteor.Collection Yearbook.classOf2016CharactersCollectionName
  
  constructor: ->
    super

    @setFixedPixelBoySize 384, 274

    @front = new ReactiveField null
    @middle = new ReactiveField null

    @showFront = new ReactiveField true

  onCreated: ->
    super

    @front new @constructor.Front @
    @middle new @constructor.Middle @
