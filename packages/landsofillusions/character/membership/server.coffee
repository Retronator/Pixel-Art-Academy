AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Character.Membership extends LOI.Character.Membership
  @Meta
    name: @id()
    replaceParent: true

  @addMember: (characterId, groupId) ->
    # Find the last member in this group.
    lastMembership = LOI.Character.Membership.documents.findOne {groupId},
      sort:
        joinTime: -1

    LOI.Character.Membership.documents.insert
      character:
        _id: characterId
      groupId: groupId
      joinTime: new Date()
      memberId: (lastMembership?.memberId or 0) + 1
