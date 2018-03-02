AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.JournalView.JournalDesign extends AM.Component
  constructor: (@journalView) ->
    super

    @entryEditor = new ReactiveField null

  onCreated: ->
    super
    
    @entryEditor new PAA.PixelBoy.Apps.Journal.JournalView.EntryEditor @

  # Override to provide desired PixelBoy size.
  pixelBoySize: -> throw new AE.NotImplementedException "You must provide PixelBoy size."

  # Override to provide where the user should be able to write on the page.
  writingAreaOptions: -> throw new AE.NotImplementedException "You must provide writing area options."

  events: ->
    super.concat
      'click .previous.page-button': @onClickPreviousPageButton
      'click .next.page-button': @onClickNextPageButton

  onClickPreviousPageButton: (event) ->
    @entryEditor().previousPage()

  onClickNextPageButton: (event) ->
    @entryEditor().nextPage()
