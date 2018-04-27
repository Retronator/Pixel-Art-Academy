LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Groups.SanFranciscoFriends extends PAA.Groups.HangoutGroup
  # Uses character groups to allow player to add their own characters to friends.
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Groups.SanFranciscoFriends'

  @fullName: -> "San Francisco friends"
  @location: -> HQ.Cafe

  @initialize()

  constructor: ->
    @memberIds = new ComputedField =>
      group = LOI.Character.Group.documents.findOne
        'character._id': LOI.characterId()
        groupId: @id()

      return [] unless group

      member._id for member in group.members

    @members = new ComputedField =>
      LOI.Character.getPerson memberId for memberId in @memberIds()

    # Call super last because member ids need to be prepared.
    super

  @isCharacterMember: (characterIdOrInstance) ->
    LOI.Character.Group.isCharacterMember @id(), characterIdOrInstance
