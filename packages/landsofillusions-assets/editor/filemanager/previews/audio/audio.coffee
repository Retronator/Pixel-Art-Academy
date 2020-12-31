AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Editor.FileManager.Previews.Audio extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Editor.FileManager.Previews.Audio'
  @register @id()

  constructor: ->
    super arguments...

    @$canvas = new ReactiveField null
    @canvas = new ReactiveField null
    @context = new ReactiveField null

  onCreated: ->
    super arguments...

    @previewCanvas = new ComputedField =>
      audio = @data()

      # Subscribe to asset and palette.
      LOI.Assets.Asset.forId.subscribe @, LOI.Assets.Audio.className, audio._id

      # Get full audio data.
      audio = LOI.Assets.Audio.documents.findOne audio._id

      # Make sure we have nodes, otherwise the audio is either empty or hasn't been fully loaded yet.
      return unless audio.nodes

      audio.getPreviewImage()

  onRendered: ->
    super arguments...

    # DOM has been rendered, initialize.
    $canvas = @$('.canvas')
    canvas = $canvas[0]
    context = canvas.getContext '2d'

    # Redraw canvas routine.
    @autorun =>
      return unless previewCanvas = @previewCanvas()

      canvas.width = previewCanvas.width
      canvas.height = previewCanvas.height

      context.drawImage previewCanvas, 0, 0
