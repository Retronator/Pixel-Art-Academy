AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Memory.Action.insert.method (memoryId, characterId, type, content) ->
  check memoryId, Match.DocumentId
  check characterId, Match.DocumentId
  check type, typePattern
  check content, actionContentPattern

  LOI.Authorize.characterAction characterId

  # Memory must exist.
  memory = LOI.Memory.documents.findOne memoryId
  throw new AE.ArgumentException "Memory not found." unless memory

  LOI.Memory.Action.documents.insert
    time: new Date()
    memory:
      _id: memoryId
    character:
      _id: characterId
      # Insert name as well, to prevent "No Name" before de-normalization happens.
      avatar:
        fullName: LOI.Character.documents.findOne(characterId).avatar.fullName
    type: type
    content: content

LOI.Memory.Action.changeContent.method (memoryId, content) ->
  check memoryId, Match.DocumentId
  check content, actionContentPattern

  # Make sure the user can change this line.
  authorizeMemoryAction memoryId

  LOI.Memory.Action.documents.update
    $set: {content}

authorizeMemoryAction = (memoryId) ->
  # Action must exist.
  action = LOI.Memory.Action.documents.findOne memoryId
  throw new AE.ArgumentException "Line not found." unless action

  # Make sure the user controls the character of this line.
  LOI.Authorize.characterAction action.character._id
  
typePattern = Match.Where (value) ->
  check value, String
  
  value in _.values LOI.Memory.Action.Types

actionContentPattern = Match.ObjectIncluding
  say: Match.Optional
    text: String
