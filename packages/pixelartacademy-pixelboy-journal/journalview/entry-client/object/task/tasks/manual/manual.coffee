AM = Artificial.Mirage
PAA = PixelArtAcademy
Entry = PAA.PixelBoy.Apps.Journal.JournalView.Entry

class Entry.Object.Task.Manual extends AM.Component
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Journal.JournalView.Entry.Object.Task.Manual'
  @version: -> '0.1.0'

  @register @id()
  template: -> @constructor.id()
