LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1
HQ = Retronator.HQ

class C1.Groups.SanFranciscoFriends extends PAA.Groups.HangoutGroup
  # members: map of all friends (active and inactive)
  #   {characterId}
  #     id
  #     active: boolean if this is a current friend
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Groups.SanFranciscoFriends'

  @fullName: -> "San Francisco friends"
  @location: -> HQ.Cafe

  @listeners: ->
    super(arguments...).concat [
      @HangoutGroupListener
    ]

  @initialize()

  constructor: ->
    super arguments...

    @_members = new ReactiveField []

    # Update members when the state of members changes.
    membersField = @state.field 'members'

    @_membersAutorun = Tracker.autorun =>
      members = membersField() or []
      memberIds = (memberId for memberId, member of members when member.active)

      # React only to changes in member IDs.
      Tracker.nonreactive =>
        @_members (LOI.Character.getPerson memberId for memberId in memberIds)

    @constructed true

  destroy: ->
    super arguments...

    @_membersAutorun.stop()

  members: ->
    return unless @constructed()

    @_members()

  startMainQuestionsWithPerson: (person) ->
    # Start a default SF conversation.
    conversation = LOI.adventure.getCurrentThing C1.SanFranciscoConversation
    conversation.startMainQuestionsWithPerson person

  # Hangout group parts

  class @HangoutGroupListener extends PAA.Groups.HangoutGroup.GroupListener
    @id: -> "PixelArtAcademy.Season1.Episode1.Chapter1.Groups.SanFranciscoFriends.HangoutGroupListener"

    @scriptUrls: -> [
      'retronator_pixelartacademy-season1-episode1/chapter1/groups/sanfranciscofriends/sanfranciscofriends.script'
    ]

    class @Script extends PAA.Groups.HangoutGroup.GroupListener.Script
      @id: -> "PixelArtAcademy.Season1.Episode1.Chapter1.Groups.SanFranciscoFriends"
      @initialize()

    @initialize()
