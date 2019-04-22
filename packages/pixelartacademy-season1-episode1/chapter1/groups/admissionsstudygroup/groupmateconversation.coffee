AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy

C1 = PAA.Season1.Episode1.Chapter1
Vocabulary = LOI.Parser.Vocabulary

class C1.Groups.AdmissionsStudyGroup.GroupmateConversation extends LOI.Adventure.Scene.ConversationBranch
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup.GroupmateConversation'

  @location: ->
    # Applies to all locations, but has filtering to match your study group's members.
    null

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/groups/admissionsstudygroup/groupmateconversation.script'
  @returnLabel: -> 'MainQuestions'

  constructor: ->
    super arguments...

  destroy: ->
    super arguments...

  prepareScriptForGroupmate: (groupmate) ->
    script = @listeners[0].script

    # Replace the groupmate with target character.
    script.setThings {groupmate}

    # Transfer ephemeral state for the groupmate from main to this script.
    ephemeralPersons = script._mainScript.ephemeralState 'persons'
    ephemeralGroupmate = ephemeralPersons[groupmate._id]
    script.ephemeralState 'groupmate', ephemeralGroupmate

  # Script

  initializeScript: ->
    super arguments...

  # Listener

  onEnter: (enterResponse) ->
    scene = @options.parent

    # Subscribe to see group members.
    @_studyGroupMembershipAutorun = Tracker.autorun (computation) =>
      return unless studyGroupId = C1.readOnlyState 'studyGroupId'
      C1.Groups.AdmissionsStudyGroup.groupMembers.subscribe LOI.characterId(), studyGroupId

  cleanup: ->
    super arguments...

    @_studyGroupMembershipAutorun?.stop()

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    super arguments...

    scene = @options.parent

    return unless choicePlaceholderResponse.placeholderId is 'PersonConversationMainQuestions'

    # This choices only apply to members of your study group.
    return unless studyGroupId = C1.readOnlyState 'studyGroupId'
    group = LOI.adventure.getThing studyGroupId
    members = group.members()

    person = choicePlaceholderResponse.script.things.person
    return unless person in members
    groupmate = person

    # Save the script so we can access its ephemeral state.
    @script._mainScript = choicePlaceholderResponse.script

    choicePlaceholderResponse.addChoices @script.startNode.labels.MainQuestions.next

    # Prepare script for talking about this groupmate.
    Tracker.nonreactive => scene.prepareScriptForGroupmate groupmate
