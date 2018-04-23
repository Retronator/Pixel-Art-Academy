AB = Artificial.Babel
AE = Artificial.Everywhere
LOI = LandsOfIllusions

LOI.Character.Group.addMember.method (characterId, groupId, memberId) ->
  check characterId, Match.DocumentId
  check groupId, String
  check memberId, Match.DocumentId

  LOI.Authorize.player()
  LOI.Authorize.characterAction characterId

  group = requireGroup characterId, groupId

  member = LOI.Character.documents.findOne memberId
  throw new AE.ArgumentException "Member does not exist." unless member

  throw new AE.ArgumentException "Member is already in this group." if group.isCharacterMember member

  LOI.Character.Group.documents.update
    'character._id': characterId
    groupId: groupId
  ,
    $addToSet:
      members:
        _id: memberId

requireGroup = (characterId, groupId) ->
  query =
    'character._id': characterId
    groupId: groupId
  
  group = LOI.Character.Group.documents.findOne query
    
  unless group
    LOI.Character.Group.documents.insert
      character:
        _id: characterId
      groupId: groupId
      members: []

    group = LOI.Character.Group.documents.findOne query
      
  group
