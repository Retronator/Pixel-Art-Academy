AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.JournalView.JournalDesign extends AM.Component
  constructor: (@journalView, @journalId) ->
    super

    @entries = new ReactiveField null

  onCreated: ->
    super
    
    @journalDocument = new ComputedField =>
      PAA.Practice.Journal.documents.findOne @journalId

    @entries new PAA.PixelBoy.Apps.Journal.JournalView.Entries @

  # Override to provide desired PixelBoy size.
  pixelBoySize: -> throw new AE.NotImplementedException "You must provide PixelBoy size."

  # Override to provide where the user should be able to write on the page.
  writingAreaOptions: -> throw new AE.NotImplementedException "You must provide writing area options."
