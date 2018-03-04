AB = Artificial.Babel
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Entry = PAA.PixelBoy.Apps.Journal.JournalView.Entry

Quill = require 'quill'
BlockEmbed = Quill.import 'blots/block/embed'

class Entry.Object.Artwork extends Entry.Object
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry.Object.Artwork'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()

  @registerBlot 'artwork'
