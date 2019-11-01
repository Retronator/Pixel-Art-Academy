AM = Artificial.Mummification
LOI = LandsOfIllusions

class LOI.Character.Part extends LOI.Character.Part
  getPreviewImage: ->
    # Determine renderer options.
    rendererOptions =
      useDatabaseSprites: true

    if _.startsWith @options.type, 'Avatar.Outfit'
      rendererOptions.landmarksSource = =>
        unless @constructor._defaultBodyRenderer
          @constructor._defaultBodyPart = LOI.Character.Part.Types.Avatar.Body.create
            dataLocation: new AM.Hierarchy.Location
              rootField: AM.Hierarchy.create
                templateClass: LOI.Character.Part.Template
                type: LOI.Character.Part.Types.Avatar.Body.options.type
                load: => null

          @constructor._defaultBodyRenderer = @constructor._defaultBodyPart.createRenderer
            useArticleLandmarks: true
            useDatabaseSprites: true

        @constructor._defaultBodyRenderer

      rendererOptions.centerOnUsedLandmarks = true
      rendererOptions.ignoreRenderingConditions = true

      rendererOptions.bodyPart = => @constructor._defaultBodyPart

    # Render the part.
    renderer = @createRenderer rendererOptions
    previewImage = renderer.getPreviewImage rootPart: @
    renderer.destroy()

    previewImage

  getPreviewText: ->
    @toString()
