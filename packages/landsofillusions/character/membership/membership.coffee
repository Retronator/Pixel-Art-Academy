AM = Artificial.Mummification
LOI = LandsOfIllusions

# Membership information for storyline-managed groups
class LOI.Character.Membership extends AM.Document
  @id: -> 'LandsOfIllusions.Character.Membership'
  # character: the character
  #   _id
  # groupId: ID of the group as used in Adventure Group objects
  # joinTime: the time the character joined the group and got their member ID
  # memberId: sequential integer assigned when joining a group
  @Meta
    name: @id()
    fields: =>
      character: @ReferenceField LOI.Character
