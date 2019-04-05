AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1

class C1.Groups.AdmissionsStudyGroup extends PAA.Groups.HangoutGroup
  # Uses membership to determine its members for the current character.
  @fullName: -> "admissions study group"

  # Subscriptions

  @groupMembers = new AB.Subscription
    name: "PAA.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup.groupMembers"
    query: (characterId, groupId) =>
      # Get member ID of character.
      characterMembership = LOI.Character.Membership.documents.findOne
        groupId: groupId
        'character._id': characterId

      return unless characterMembership
      memberId = characterMembership.memberId
      
      # Study group has 2 characters before and after the current character.
      LOI.Character.Membership.documents.find
        groupId: groupId
        memberId:
          $gte: memberId - 2
          $lte: memberId + 2
