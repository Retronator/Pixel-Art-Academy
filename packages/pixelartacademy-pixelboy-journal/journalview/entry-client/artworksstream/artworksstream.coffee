AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Journal.JournalView.Entry.ArtworksStream extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry.ArtworksStream'
  @register @id()

  constructor: (@artworks) ->
    super arguments...

    @activatable = new LOI.Components.Mixins.Activatable()

  mixins: -> [@activatable]

  onRendered: ->
    super arguments...

    $(window).scrollTop 0

  onDestroyed: ->
    super arguments...

    $(window).scrollTop 0

  streamOptions: ->
    scrollParentSelector: '.pixelartacademy-pixelboy-apps-journal-journalview-entry-artworksstream'
    display: LOI.adventure.interface.display

  events: ->
    super(arguments...).concat
      'click': @onClick

  onClick: (event) ->
    @activatable.deactivate()
