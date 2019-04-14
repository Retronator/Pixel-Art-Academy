AB = Artificial.Babel
LOI = LandsOfIllusions
PAA = PixelArtAcademy

C1 = PAA.Season1.Episode1.Chapter1

class C1.Groups.AdmissionsStudyGroup.Conversation extends LOI.Memory.Context
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup.Conversation'

  @initialize()

  @description: -> "You ask a question to your study group."

  @translations: ->
    introDescription: "_people_ _are_ talking at a study group meeting."

  @createIntroDescriptionScript: (memory, people, nextNode, nodeOptions) ->
    description = AB.translate(@translationHandle, 'introDescription').text

    @_createDescriptionScript people, description, nextNode, nodeOptions

Meteor.startup =>
  LOI.Items.Sync.Memories.registerPreviewComponent C1.Groups.AdmissionsStudyGroup.Conversation.id(), LOI.Memory.Contexts.Conversation.MemoryPreview
