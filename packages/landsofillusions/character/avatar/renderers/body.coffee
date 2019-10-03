LOI = LandsOfIllusions

class LOI.Character.Avatar.Renderers.Body extends LOI.Character.Avatar.Renderers.BodyPart
  _createRenderers: ->
    @leftArmRenderer = @_createRenderer 'arms',
      regionSide: 'Left'
    
    @rightArmRenderer = @_createRenderer 'arms',
      flippedHorizontal: true
      regionSide: 'Right'
    
    @rightArmRenderer._flipHorizontal = true
    
    @torsoRenderer = @_createRenderer 'torso'
    
    @headRenderer = @_createRenderer 'head'
    
    @leftLegRenderer = @_createRenderer 'legs',
      regionSide: 'Left'
    
    @rightLegRenderer = @_createRenderer 'legs',
      flippedHorizontal: true
      regionSide: 'Right'
    
    @rightLegRenderer._flipHorizontal = true

  _placeRenderers: (side) ->
    # Place the torso.
    @_placeRenderer side, @torsoRenderer, 'vertebraL3', 'vertebraL3'

    # Place the head.
    @_placeRenderer side, @headRenderer, 'atlas', 'atlas'

    # Place the legs.
    @_placeRenderer side, @leftLegRenderer, 'acetabulum', 'acetabulumLeft'
    @_placeRenderer side, @rightLegRenderer, 'acetabulum', 'acetabulumRight'

    # Place the arms.
    @_placeRenderer side, @leftArmRenderer, 'shoulder', 'shoulderLeft'
    @_placeRenderer side, @rightArmRenderer, 'shoulder', 'shoulderRight'

  _applyLandmarksRegion: (landmarks) ->
    super arguments...

    # Body renderer needs to also position additional rendering regions landmarks.
    return unless @options.renderTexture

    for region in [
      LOI.HumanAvatar.Regions.HairFront
      LOI.HumanAvatar.Regions.HairMiddle
      LOI.HumanAvatar.Regions.HairBehind
      LOI.HumanAvatar.Regions.TorsoClothes
    ]
      unpositionedLandmarks = _.filter landmarks, (landmark) => landmark.regionId is region.id
      _.pullAll landmarks, unpositionedLandmarks

      # Start with the region origin.
      origin = region.options.origin
      bounds = region.options.bounds

      positionedLandmarks = [
        name: origin.landmark
        x: origin.x + bounds.x()
        y: origin.y + bounds.y()
      ]

      positioned = true

      # Position landmarks until done.
      while unpositionedLandmarks.length
        positioned = false

        # Find an unpositioned landmark that matches a positioned one.
        targetLandmark = null

        matchedLandmark = _.find unpositionedLandmarks, (unpositionedLandmark) =>
          targetLandmark = _.find positionedLandmarks, (positionedLandmark) => positionedLandmark.name is unpositionedLandmark.name
          targetLandmark

        break unless matchedLandmark

        # Calculate translation.
        translation =
          x: targetLandmark.x - matchedLandmark.x
          y: targetLandmark.y - matchedLandmark.y

        # Translate all landmarks in the matched landmark's source region and add them to positioned landmarks.
        sourceRegionLandmarks = _.filter unpositionedLandmarks, (landmark) => landmark.sourceRegionId is matchedLandmark.sourceRegionId

        for sourceRegionLandmark in sourceRegionLandmarks
          targetLandmark = _.clone sourceRegionLandmark
          targetLandmark.x += translation.x
          targetLandmark.y += translation.y

          positionedLandmarks.push targetLandmark
          _.pull unpositionedLandmarks, sourceRegionLandmark

      # Update landmarks.
      landmarks.push positionedLandmarks...

  drawToContext: (context, options = {}) ->
    return unless @ready()

    # Draw the hair behind and in the middle first.
    context.save()

    # Depend on landmarks to update when head renderer translations change.
    @landmarks[options.side]()

    translation = _.defaults {}, @headRenderer._translation[options.side],
      x: 0
      y: 0

    context.translate translation.x, translation.y

    @headRenderer.drawHairRenderersToContext 'HairBehind', context, options
    @headRenderer.drawHairRenderersToContext 'HairMiddle', context, options

    context.restore()

    # Draw the rest as usual.
    super arguments...
