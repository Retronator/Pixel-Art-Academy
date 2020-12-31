LOI = LandsOfIllusions
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class C1.Mixer.Context extends LOI.Adventure.Context
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.Mixer.Context'
  @isPrivate: -> true

  @initialize()

  illustration: ->
    # The camera angle doesn't change until the mixer interactions start.
    return unless C1.Mixer.GalleryWest.Listener.Script.state 'MixerStart'

    if C1.Mixer.GalleryWest.Listener.Script.state 'CoordinatorIntro'
      studyGroupId = C1.readOnlyState 'studyGroupId'
      letter = _.last studyGroupId

      cameraAngle = "Mixer group #{letter}"

    else
      cameraAngle = 'Mixer'

    {cameraAngle}

  # Listener
  
  onCommand: (commandResponse) ->
    # We override the parent implementation (and not call super) 
    # since we don't want the back command to exit the context.
