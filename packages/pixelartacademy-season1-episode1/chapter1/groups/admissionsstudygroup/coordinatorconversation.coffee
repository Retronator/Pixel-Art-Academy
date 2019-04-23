AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

C1 = PAA.Season1.Episode1.Chapter1
Vocabulary = LOI.Parser.Vocabulary

class C1.Groups.AdmissionsStudyGroup.CoordinatorConversation extends LOI.Adventure.Scene.ConversationBranch
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup.CoordinatorConversation'

  @location: ->
    # Applies to all locations, but has filtering to match study group coordinators.
    null

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/groups/admissionsstudygroup/coordinatorconversation.script'
  @returnLabel: -> 'MainQuestions'

  prepareScriptForCoordinator: (@currentCoordinator) ->
    script = @listeners[0].script

    # Replace the coordinator with target character.
    script.setThings coordinator: @currentCoordinator

  # Listener

  onChoicePlaceholder: (choicePlaceholderResponse) ->
    super arguments...

    scene = @options.parent

    return unless choicePlaceholderResponse.placeholderId is 'CoordinatorMainQuestions'

    coordinator = choicePlaceholderResponse.script.things.coordinator
    return unless C1.Mixer.finished() or coordinator instanceof HQ.Actors.Shelley

    # Save the script so we can access its ephemeral state.
    @script._mainScript = choicePlaceholderResponse.script

    choicePlaceholderResponse.addChoices @script.startNode.labels.CoordinatorMainQuestions.next

    # Prepare script for talking with this coordinator.
    Tracker.nonreactive => scene.prepareScriptForCoordinator coordinator
