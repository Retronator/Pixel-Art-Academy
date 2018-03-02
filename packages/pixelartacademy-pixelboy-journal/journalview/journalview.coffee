AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.JournalView extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  constructor: (@journal) ->
    super

    @journalDesign = new ReactiveField null
    @visible = new ReactiveField false

  onCreated: ->
    super

    @autorun (computation) =>
      journalId = @journal.journalId()

      # React only to id and type changes.
      journalDocument = PAA.Practice.Journal.documents.findOne journalId,
        fields:
          'design.type': 1

      Tracker.nonreactive =>
        if journalDocument
          @journalDesign new @constructor.JournalDesign[journalDocument.design.type] @
          @visible true

        else if @visible()
          @visible false

          Meteor.setTimeout =>
            @journalDesign null
          ,
            500

  visibleClass: ->
    'visible' if @visible()
