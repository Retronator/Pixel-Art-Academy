AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal extends PAA.PixelBoy.App
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal'
  @url: -> 'journal'

  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @fullName: -> "Journal"
  @description: ->
    "
      You can write about your projects in it.
    "

  @initialize()

  constructor: ->
    super

    @setDefaultPixelBoySize()

    @journalsView = new ReactiveField null

  onCreated: ->
    super

    @journalsView new @constructor.JournalsView @
