AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.Editor.References.DisplayComponent.Reference extends LOI.Assets.Components.References.Reference
  @id: -> 'LandsOfIllusions.Assets.Editor.References.DisplayComponent.Reference'
  @register @id()

  constructor: ->
    super arguments...

    @resizingBorder = 2

  onCreated: ->
    super arguments...

  displayModeClass: ->
    _.kebabCase @currentDisplayMode()

  referenceStyle: ->
    scale = @currentScale()

    resizingScale = @resizingScale()
    scale = resizingScale if resizingScale?

    # We calculate the display size using the potentially resizing scale.
    return display: 'none' unless displaySize = @displaySize scale

    position = @draggingPosition() or @currentPosition()

    currentDisplayMode = @currentDisplayMode()

    if currentDisplayMode in [LOI.Assets.VisualAsset.ReferenceDisplayModes.EmbeddedUnder, LOI.Assets.VisualAsset.ReferenceDisplayModes.EmbeddedOver]
      # We're positioned relative to image origin.
      embeddedTransform = @references.options.embeddedTransform()

      # Note: We need to create a new object, so we don't modify the source position.
      position =
        x: (position.x - embeddedTransform.origin.x) * embeddedTransform.scale
        y: (position.y - embeddedTransform.origin.y) * embeddedTransform.scale

      displaySize.width *= embeddedTransform.scale
      displaySize.height *= embeddedTransform.scale

    left: "calc(50% + #{position.x}rem)"
    top: "calc(50% + #{position.y}rem)"
    width: "#{displaySize.width}rem"
    height: "#{displaySize.height}rem"
