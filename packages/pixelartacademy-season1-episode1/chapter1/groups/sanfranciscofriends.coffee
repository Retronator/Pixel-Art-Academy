LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Groups.SanFranciscoFriends extends PAA.Groups.HangoutGroup
  # members: map of all friends (active and inactive)
  #   {characterId}
  #     _id
  #     active: boolean if this is a current friend
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Groups.SanFranciscoFriends'

  @fullName: -> "San Francisco friends"
  @location: -> HQ.Cafe

  @initialize()

  constructor: ->
    @members = new ReactiveField []

    # Call super after because members need to be prepared.
    super

    # Update members when the state of members changes.
    membersField = @state.field 'members'

    @_membersAutorun = Tracker.autorun =>
      members = membersField() or []
      memberIds = (memberId for memberId, member of members when member.active)

      # React only to changes in member IDs.
      Tracker.nonreactive =>
        @members (LOI.Character.getPerson memberId for memberId in memberIds)

  destroy: ->
    super

    @_membersAutorun.stop()
