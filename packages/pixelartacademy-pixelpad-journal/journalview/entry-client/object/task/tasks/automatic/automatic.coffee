AM = Artificial.Mirage
PAA = PixelArtAcademy
Entry = PAA.PixelPad.Apps.Journal.JournalView.Entry

class Entry.Object.Task.Automatic extends Entry.Object.Task.Component
  @id: -> 'PixelArtAcademy.PixelPad.Apps.Journal.JournalView.Entry.Object.Task.Automatic'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()
