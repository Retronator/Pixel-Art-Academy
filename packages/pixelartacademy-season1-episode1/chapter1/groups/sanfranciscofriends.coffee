LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Groups.SanFranciscoFriends extends LOI.Adventure.Group
  # Uses character groups to allow player to add their own characters to friends.
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Groups.SanFranciscoFriends'

  @fullName: -> "San Francisco friends"
  @location: -> HQ.Cafe

  @initialize()

  constructor: ->
    super

    @memberIds = new ComputedField =>
      group = LOI.Character.Group.documents.findOne
        'character._id': LOI.characterId()
        groupId: @id()

      return [] unless group

      member._id for member in group.members
      
    @members = new ComputedField =>
      LOI.Character.getPerson memberId for memberId in @memberIds()

  @isCharacterMember: (characterIdOrInstance) ->
    LOI.Character.Group.isCharacterMember @id(), characterIdOrInstance
