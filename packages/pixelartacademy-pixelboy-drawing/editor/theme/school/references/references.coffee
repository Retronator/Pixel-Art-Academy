AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy.Apps.Drawing.Editor.Theme.School.References extends LOI.Assets.Components.References
  @id: -> 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Theme.School.References'
  @register @id()

  onCreated: ->
    super

    @opened = new ReactiveField false

  styleClasses: ->
    classes = [
      'opened' if @opened()
    ]

    _.without(classes, undefined).join ' '
    
  events: ->
    super.concat
      'click .stored-references': @onClickStoredReferences

  onClickStoredReferences: (event) ->
    $target = $(event.target)
    opened = @opened()

    # Don't react to clicks on references to prevent opening on drag end.
    return if $target.closest('.reference').length

    if opened
      # Only react to clicks directly on the stored references.
      return if $target.closest('.actions').length

    @opened not opened

  class @Reference extends LOI.Assets.Components.References.Reference
    @register 'PixelArtAcademy.PixelBoy.Apps.Drawing.Editor.Theme.School.References.Reference'

    constructor: ->
      super

      @trayWidth = 165

    onCreated: ->
      super

      # Automatically scale the image when not displayed.
      @autorun (computation) =>
        reference = @data()

        return unless size = @size()

        # Scale should be such that 100^2 pixels are covered, but any side is not larger than 150 pixels.
        scale = Math.min 100 / Math.sqrt(size.width * size.height), Math.min 150 / size.width, 150 / size.height

        return if reference.scale is scale

        # Update scale.
        if reference.image
          LOI.Assets.VisualAsset.updateReferenceScale @references.options.assetId(), @references.options.documentClass.className, reference.image._id, scale

        else
          # This is an image that is still uploading so set the scale directly to data as it will be uploaded later.
          @scale scale

      # Close references when moving outside the tray.
      @autorun (computation) =>
        return unless @references.opened()
        return unless draggingPosition = @draggingPosition()
        return unless size = @size()
        scale = @currentScale()

        if Math.abs(draggingPosition.x) + size.width * scale / 2 > @trayWidth / 2
          @references.opened false
