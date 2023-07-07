AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Practice.Journal.Entry.MemoryPreview extends AM.Component
  @id: -> 'PixelArtAcademy.Practice.Journal.Entry.MemoryPreview'
  @register @id()

  Meteor.startup =>
    LOI.Items.Sync.Memories.registerPreviewComponent 'PixelArtAcademy.PixelPad.Apps.Journal.JournalView.Context', @

  onCreated: ->
    super arguments...

    memory = @data()

    # Subscribe to receive the full details of the journal entry.
    PAA.Practice.Journal.Entry.forId.subscribe @, memory.journalEntry[0]._id

    @memories = @ancestorComponentOfType LOI.Items.Sync.Memories

  authorImageUrl: ->
    memory = @data()

    @memories.getCharacterImage memory.journalEntry[0].journal.character._id

  journalEntry: ->
    memory = @data()

    # We need to unwrap the array holding the one journal entry.
    memory.journalEntry[0].refresh()

  imagePreviewUrl: ->
    content = @journalEntry().content

    return unless pictureElement = _.find content, (element) => element.insert.picture

    pictureElement.insert.picture.url
