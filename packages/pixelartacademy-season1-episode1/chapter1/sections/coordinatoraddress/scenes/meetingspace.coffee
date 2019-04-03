LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.CoordinatorAddress.MeetingSpace extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.CoordinatorAddress.MeetingSpace'

  @location: ->
    # Location is determined by which group the character joined.
    null

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/sections/coordinatoraddress/scenes/meetingspace.script'

  @initialize()

  group: ->
    return unless studyGroupId = C1.readOnlyState 'studyGroupId'
    LOI.Adventure.Thing.getClassForId studyGroupId

  location: ->
    @group().location()

  things: ->
    return unless group = @group()

    coordinator = group.coordinator()

    _.flatten [
      # Only Shelley is not at the location yet.
      coordinator if coordinator is HQ.Actors.Shelley
      group.npcMembers()
    ]
    
  initializeScript: ->
    scene = @options.parent

  onEnter: (enterResponse) ->
    scene = @options.parent

    # Coordinator should talk when at location.
    @_coordinatorTalksAutorun = @autorun (computation) =>
      return unless @scriptsReady()
      return unless group = scene.group()
      return unless coordinator = LOI.adventure.getCurrentThing group.coordinator()
      return unless coordinator.ready()

      npcMembers = group.npcMembers()
      return unless npc1 = LOI.adventure.getCurrentThing npcMembers[0]
      return unless npc2 = LOI.adventure.getCurrentThing npcMembers[1]
      return unless npc1.ready() and npc2.ready()

      computation.stop()

      @script.setThings {coordinator, npc1, npc2}

      C1.prepareGroupInfoInScript @script
      @startScript()
      
  cleanup: ->
    @_coordinatorTalksAutorun?.stop()
