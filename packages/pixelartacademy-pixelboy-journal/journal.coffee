AB = Artificial.Base
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
    @journalView = new ReactiveField null

    @journalId = new ComputedField =>
      AB.Router.getParameter 'parameter3'

  onCreated: ->
    super

    @journalsView new @constructor.JournalsView @
    @journalView new @constructor.JournalView @

    @autorun (computation) =>
      if journalDesign = @journalView().journalDesign()
        width = journalDesign.width()
        height = journalDesign.height()

        @minWidth width
        @minHeight height

        @maxWidth width
        @maxHeight height

        @resizable false

      else
        @setDefaultPixelBoySize()
