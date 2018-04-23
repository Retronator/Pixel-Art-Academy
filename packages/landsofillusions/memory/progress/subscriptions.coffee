LOI = LandsOfIllusions

LOI.Memory.Progress.forCharacter.publish (characterId) ->
  check characterId, Match.DocumentId

  # Only allow to subscribe to your own character.
  LOI.Authorize.characterAction characterId
  
  # Create the progress document if it doesn't exist yet.
  progress = LOI.Memory.Progress.documents.findOne 'character._id': characterId
  
  unless progress
    LOI.Memory.Progress.documents.insert
      character:
        _id: characterId
      observedMemories: []
  
  LOI.Memory.Progress.documents.find 'character._id': characterId
