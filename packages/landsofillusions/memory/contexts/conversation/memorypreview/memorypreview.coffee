AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Memory.Contexts.Conversation.MemoryPreview extends AM.Component
  @id: -> 'LandsOfIllusions.Memory.Contexts.Conversation.MemoryPreview'
  @register @id()

  Meteor.startup =>
    LOI.Items.Sync.Memories.registerPreviewComponent 'LandsOfIllusions.Memory.Contexts.Conversation', @
