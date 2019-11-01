AE = Artificial.Everywhere
AC = Artificial.Control
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Navigator extends LOI.Assets.Editor.Navigator
  @id: -> "LandsOfIllusions.Assets.AudioEditor.Navigator"
  @register @id()

  template: -> @constructor.id()

  getThumbnailSpriteData: ->
    # We don't use the sprite system to draw the thumbnail.
    null

  onRendered: ->
    super arguments...

    $thumbnail = @$('.thumbnail')

    # Update thumbnail reactively.
    @autorun (computation) =>
      return unless audioCanvas = @editor()
      return unless audio = audioCanvas.audioData()

      # Replace preview image.
      $thumbnail.empty()
      $canvas = $(audio.getPreviewImage()).addClass('canvas')
      $thumbnail.append $canvas
