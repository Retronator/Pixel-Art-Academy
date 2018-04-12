AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Memory.Action.do.method (type, characterId, situation, content, memoryId) ->
  check type, typePattern
  check characterId, Match.DocumentId
  check situation, situationPattern
  check content, LOI.Memory.Action.contentPatterns[type] if LOI.Memory.Action.contentPatterns[type]
  check memoryId, Match.Optional Match.DocumentId

  LOI.Authorize.characterAction characterId

  action =
    type: type
    time: new Date()
    timelineId: situation.timelineId
    locationId: situation.locationId
    character:
      _id: characterId

  action.contextId = situation.contextId if situation.contextId
  action.content = content if content

  actionClass = LOI.Memory.Action.getClassForType type
  action.isMemorable = true if actionClass.isMemorable()

  if memoryId
    memory = LOI.Memory.documents.findOne memoryId

    # Memory must exist.
    unless memory
      # On the client it could not be loaded yet, so just quit in that case.
      # It'll get processed on the server and sent to the client eventually
      return if Meteor.isClient

      throw new AE.ArgumentException "Memory not found."

    # Within memories, we insert this as a new action.
    action.memory = _id: memoryId

    LOI.Memory.Action.documents.insert action
    
    # Also automatically progress this memory to the end for this character.
    LOI.Memory.Progress.updateProgress characterId, memoryId, action.time

  else if action.isMemorable
    # Memorable actions need to be normally inserted.
    LOI.Memory.Action.documents.insert action

  else
    # Outside of memories and memorable actions, we replace this character's last action.
    LOI.Memory.Action.documents.upsert
      'character._id': characterId
      memoryId: $exists: false
      isMemorable: $ne: true
    ,
      action

LOI.Memory.Action.updateTimeAndSituation.method (actionId, time, situation) ->
  check actionId, Match.DocumentId
  check time, Match.OptionalOrNull Date
  check situation, Match.OptionalOrNull situationPattern
  
  # Update to current time unless specified.
  time ?= new Date()
  
  setModifier = {time}
  setModifier.situation = situation if situation

  LOI.Memory.Action.documents.update actionId,
    $set: setModifier

LOI.Memory.Action.updateContent.method (actionId, content) ->
  check actionId, Match.DocumentId

  # Make sure the user can change this action.
  authorizeMemoryAction actionId

  action = LOI.Memory.Action.documents.findOne actionId
  actionContentPattern = LOI.Memory.Action.contentPatterns[action.type]

  check content, actionContentPattern if actionContentPattern

  LOI.Memory.Action.documents.update actionId,
    $set: {content}

authorizeMemoryAction = (actionId) ->
  # Action must exist.
  action = LOI.Memory.Action.documents.findOne actionId
  throw new AE.ArgumentException "Action not found." unless action

  # Make sure the user controls the character of this line.
  LOI.Authorize.characterAction action.character._id
  
typePattern = Match.Where (value) ->
  check value, String
  
  value in _.values LOI.Memory.Action.getTypes()

situationPattern =
  timelineId: String
  locationId: String
  contextId: Match.OptionalOrNull String
