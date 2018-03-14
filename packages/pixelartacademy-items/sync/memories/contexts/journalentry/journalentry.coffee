AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Items.Sync.Memories.JournalEntry extends AM.Component
  @id: -> 'PixelArtAcademy.Items.Sync.Memories.JournalEntry'
  @register @id()

  journalEntry: ->
    memory = @data()

    # We need to unwrap the array holding the one journal entry.
    memory.journalEntry[0]
