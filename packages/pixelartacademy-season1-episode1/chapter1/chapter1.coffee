AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ
RS = Retronator.Store

class PAA.Season1.Episode1.Chapter1 extends PAA.Chapter
  # READ-ONLY
  # application:
  #   applied: boolean if character has applied for admission week
  #   applicationTime: game date when character applied
  #   applicationRealTime: real date of application, so that applications can be accepted in order
  #   accepted: boolean if accepted event has happened
  #   acceptedTime: time when accepted event has happened
  C1 = @

  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1'

  @fullName: -> "Admission Week"
  @number: -> 1

  @sections: -> [
    @Intro
    @Waiting
    @PrePixelBoy
    @PixelBoy
    @PostPixelBoy
    @AdmissionProjects
    @AdmissionProjects.Snake.Intro
    @AdmissionProjects.Snake.Drawing
    @Mixer
    @CoordinatorAddress
  ]

  @scenes: -> [
    @Inventory
    @Inbox
    @Apps
    @Editors
    @Workbench
    @Pico8Cartridges
    @SanFranciscoConversation
    @Groups.SanFranciscoFriends
    @Groups.SanFranciscoFriends.Conversation
    @Groups.Family
    @Groups.AdmissionsStudyGroup.A
    @Groups.AdmissionsStudyGroup.B
    @Groups.AdmissionsStudyGroup.C
    @Groups.AdmissionsStudyGroup.GroupmateConversation
    @Groups.AdmissionsStudyGroup.CoordinatorConversation
  ]

  @initialize()

  # We specifically set the requirement of Chapter 1 since it's used to allow students to get accepted.
  # We do it for class as well as object method, because object by default inherits from episode.
  @accessRequirement: -> RS.Items.CatalogKeys.PixelArtAcademy.PlayerAccess
  accessRequirement: -> @constructor.accessRequirement()

  # Methods

  @applyCharacter: new AB.Method name: "#{@id()}.applyCharacter"

  @reset: ->
    # Move character back to the studio.
    LOI.adventure.gameState().currentLocationId = SanFrancisco.Apartment.Studio.id()
    LOI.adventure.gameState().currentTimelineId = LandsOfIllusions.TimelineIds.Present
    LOI.adventure.gameState.updated()

    # Since this is the very first chapter, reset all main namespaces to start completely fresh.
    LOI.adventure.gameState.resetNamespaces ['LandsOfIllusions', 'Retronator', 'SanFrancisco', 'PixelArtAcademy']
  
  @prepareGroupInfoInScript: (script) ->
    return unless studyGroupId = C1.readOnlyState 'studyGroupId'
    group = LOI.Adventure.Thing.getClassForId studyGroupId

    letter = _.last studyGroupId
    location = if letter is 'C' then _.toLower(group.location().fullName()) else group.location().shortName()

    npcMembers = group.npcMembers()

    summarizeNpc = (npcClass) =>
      npc = LOI.adventure.getCurrentThing npcClass

      name: npc.shortName()
    
    npc1 = summarizeNpc npcMembers[0]
    npc2 = summarizeNpc npcMembers[1]

    studyGroup = {letter, location, npc1, npc2}

    script.ephemeralState 'studyGroup', studyGroup
    
    script.setCurrentThings
      coordinator: group.coordinator()
