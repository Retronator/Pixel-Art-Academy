AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Character.Membership extends LOI.Character.Membership
  @Meta
    name: @id()
    replaceParent: true

  @addMember: (characterId, groupId, memberIdMinimumDistance = 0) ->
    # Find the last member in this group.
    lastMembership = LOI.Character.Membership.documents.findOne {groupId},
      sort:
        joinTime: -1

    newMemberId = (lastMembership?.memberId or 0) + 1

    # Make sure the character is not already a member of this group.
    latestMembership = LOI.Character.Membership.documents.findOne
      'character._id': characterId
      groupId: groupId
    ,
      sort:
        memberId: -1

    # Any previous membership must be the minimum distance away from the new ID to be valid.
    lastValidMemberId = newMemberId - memberIdMinimumDistance

    if latestMembership?.memberId > lastValidMemberId
      console.warn "Character #{characterId} is already a member of #{groupId} within the last #{memberIdMinimumDistance} members."
      return

    LOI.Character.Membership.documents.insert
      character:
        _id: characterId
      groupId: groupId
      joinTime: new Date()
      memberId: newMemberId
