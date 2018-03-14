LOI = LandsOfIllusions
AM = Artificial.Mummification

class LOI.Memory.Progress extends AM.Document
  @id: -> 'LandsOfIllusions.Memory.Progress'
  # character: character whose memory progress we're tracking
  #   _id
  # observedMemories: array of memories that have been observed already
  #   memory: the memory being tracked
  #     _id
  #   time: the time of the last action already observed by the character
  @Meta
    name: @id()
    fields: =>
      character: @ReferenceField LOI.Character
      observedMemories: [
        memory: @ReferenceField LOI.Memory
      ]

  # Methods

  @updateProgress: @method 'updateProgress'

  # Subscriptions

  @forCharacter: @subscription 'forCharacter'
