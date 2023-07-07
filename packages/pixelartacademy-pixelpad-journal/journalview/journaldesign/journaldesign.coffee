AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelPad.Apps.Journal.JournalView.JournalDesign extends AM.Component
  constructor: (@options) ->
    super arguments...

    @entries = new ReactiveField null

  onCreated: ->
    super arguments...
    
    @journalDocument = new ComputedField =>
      if @options.journalId
        journalId = @options.journalId
        
      else
        entry = PAA.Practice.Journal.Entry.documents.findOne @options.entryId
        journalId = entry?.journal._id
        
      PAA.Practice.Journal.documents.findOne journalId

    @entries new PAA.PixelPad.Apps.Journal.JournalView.Entries @

  # Override to provide the size of this design.
  size: -> throw new AE.NotImplementedException "You must provide the size of the journal."

  # Override to provide where the user should be able to write on the page.
  writingAreaOptions: -> throw new AE.NotImplementedException "You must provide writing area options."
