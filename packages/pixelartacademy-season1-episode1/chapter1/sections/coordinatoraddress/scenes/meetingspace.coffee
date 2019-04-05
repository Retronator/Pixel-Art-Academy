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

  listenForCharacterIntroduction: ->
    @listeners[0].listenForCharacterIntroduction = true

  # Script
    
  initializeScript: ->
    scene = @options.parent

    @setCallbacks
      PlayerIntroduction: (complete) =>
        scene.listenForCharacterIntroduction()
        complete()

      MeetingEnd: (complete) =>
        # Exit context after the section had time to end.
        Meteor.setTimeout => LOI.adventure.exitContext()
        complete()

  # Listener

  onEnter: (enterResponse) ->
    scene = @options.parent

    # Player should be in the coordinator address context.
    @_enterContextAutorun = @autorun (computation) =>
      return if LOI.adventure.currentContext() instanceof C1.CoordinatorAddress.Context

      LOI.adventure.enterContext C1.CoordinatorAddress.Context
      
    # Script should start automatically when at location.
    @_scriptStartAutorun = @autorun (computation) =>
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
      
      @startScriptAtLatestCheckpoint [
        'Start'
        'AgentsIntroduction'
        'PlayerIntroduction'
        'SecondNPCIntroduction'
      ]
      
  cleanup: ->
    @_enterContextAutorun?.stop()
    @_scriptStartAutorun?.stop()

  onCommand: (commandResponse) ->
    if @listenForCharacterIntroduction
      # Hijack the say command.
      sayAction = (likelyAction) =>
        # Remove text from narrative since it will be displayed in a separate node.
        LOI.adventure.interface.narrative.removeLastCommand()

        introduction = _.trim _.last(likelyAction.translatedForm), '"'

        dialogueLine = new LOI.Adventure.Script.Nodes.DialogueLine
          actor: LOI.agent()
          line: introduction
          next: @script.startNode.labels.PlayerIntroductionEnd

        LOI.adventure.director.startNode dialogueLine

        # Create an action for this character's introduction.
        LOI.Memory.Action.do C1.CoordinatorAddress.CharacterIntroduction.type, LOI.characterId(),
          LOI.adventure.currentSituationParameters()
        ,
          {introduction}

      commandResponse.onPhrase
        form: [Vocabulary.Keys.Verbs.Say, '""']
        priority: 1
        action: sayAction

      # Allow hijack just quotes.
      commandResponse.onPhrase
        form: ['""']
        priority: 1
        action: sayAction
