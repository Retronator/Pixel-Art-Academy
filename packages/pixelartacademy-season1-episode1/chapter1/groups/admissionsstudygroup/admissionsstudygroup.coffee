AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PAA.Season1.Episode1.Chapter1

class C1.Groups.AdmissionsStudyGroup extends PAA.Groups.HangoutGroup
  # Uses membership to determine its members for the current character.
  @fullName: -> "admissions study group"

  @listeners: ->
    super(arguments...).concat [
      @HangoutGroupListener
    ]

  # Subscriptions

  @groupMembers = new AB.Subscription
    name: "PAA.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup.groupMembers"
    query: (characterId, groupId) =>
      # Get study group membership of character.
      characterMembership = LOI.Character.Membership.documents.findOne
        groupId: /PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup/
        'character._id': characterId

      if characterMembership
        if characterMembership.groupId is groupId
          # The character is requesting to find members of their own study group.
          memberId = characterMembership.memberId

        else
          # The character is requesting to find members of another study group. We should show the members that he
          # encountered during admission week, so we center the group around the character who joined at the same time
          # they did.
          joinTime = characterMembership.joinTime

      else
        # The character has not joined a group yet, so we just show the latest members of the study group.
        joinTime = new Date()

      unless memberId
        membership = LOI.Character.Membership.documents.findOne
          groupId: groupId
          joinTime:
            $lte: joinTime
        ,
          sort:
            memberId: -1

        # Get the latest member's number, or default to one (will return first three members).
        memberId = membership?.memberId or 1

      # Study group has 2 characters before and after the center character.
      LOI.Character.Membership.documents.find
        groupId: groupId
        memberId:
          $gte: memberId - 2
          $lte: memberId + 2

  members: ->
    agents = @constructor.groupMembers.query(LOI.characterId(), @constructor.id()).map (membership) =>
      LOI.Character.getAgent membership.character._id

    # For group logic purposes, character is not one of the members.
    _.pull agents, LOI.agent()

    actors = for npcClass in @constructor.npcMembers()
      LOI.adventure.getThing npcClass

    [agents..., actors...]

  things: ->
    [
      @presentMembers()...
      @constructor.coordinator()
    ]

  # Listener

  onEnter: (enterResponse) ->
    scene = @options.parent

    # Subscribe to see group members.
    @_studyGroupMembershipSubscription = C1.Groups.AdmissionsStudyGroup.groupMembers.subscribe LOI.characterId(), scene.id()

  cleanup: ->
    super arguments...

    @_studyGroupMembershipSubscription?.stop()

  # Hangout group parts

  class @HangoutGroupListener extends PAA.Groups.HangoutGroup.GroupListener
    @id: -> "PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup.HangoutGroupListener"

    @scriptUrls: -> [
      'retronator_pixelartacademy-season1-episode1/chapter1/groups/admissionsstudygroup/admissionsstudygroup.script'
    ]

    class @Script extends PAA.Groups.HangoutGroup.GroupListener.Script
      @id: -> "PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup"
      @initialize()

    @initialize()

    onScriptsLoaded: ->
      super arguments...

      scene = @options.parent
      group = scene

      @groupScript.setCurrentThings
        coordinator: scene.constructor.coordinator()

      @groupScript.setCallbacks
        ReportProgress: (complete) =>
          # Delete choice being output to narrative.
          LOI.adventure.interface.narrative.removeLastCommand()

          # Pause current callback node so dialogues can execute.
          LOI.adventure.director.pauseCurrentNode()

          person = LOI.agent()

          group.characterUpdatesHelper.person person

          script = group.personUpdates.getScript
            person: person
            justUpdate: true
            readyField: group.characterUpdatesHelper.ready
            nextNode: null
            endUpdateCallback: =>
              complete()

          LOI.adventure.director.startScript script, label: 'JustUpdateStart'
