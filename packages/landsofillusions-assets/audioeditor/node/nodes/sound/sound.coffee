AB = Artificial.Babel
AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Node.Sound extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.Node.Sound'
  @register @id()
  
  constructor: (@node) ->
    super arguments...

  onCreated: ->
    super arguments...
    
    @interface = @ancestorComponentOfType FM.Interface

    @audioNode = new ComputedField =>
      return unless audio = @node.audioCanvas.audio()
      audio.getNode @node.id

  onRendered: ->
    super arguments...

    # Draw the waveform.
    @autorun (computation) =>
      canvas = @$('.waveform-canvas')[0]
      context = canvas.getContext '2d'

      context.clearRect 0, 0, 100, 20

      context.strokeStyle = "#7c8ce0"
      context.lineWidth = 1
      context.beginPath()

      context.moveTo 0, 10.5

      if buffer = @audioNode()?.buffer()
        channelData = buffer.getChannelData 0
        step = Math.floor channelData.length / 1000

        for sample, index in channelData by step
          context.lineTo 100 * index / channelData.length, 10 * (1 + sample)

      context.lineTo 100, 10.5
      context.stroke()

      canvas

  events: ->
    super(arguments...).concat
      'click .open-button': @onClickOpenButton
      'drop .open': @onDropOpen
  
  onClickOpenButton: (event) ->
    url = @node.parametersData()?['url']
    
    @interface.displayDialog
      contentComponentId: LOI.Assets.AudioEditor.SoundSelectDialog.id()
      contentComponentData:
        selectItem: url
        open: (selectedItem) =>
          @node.audioCanvas.audioLoader().changeNodeParameter @node.id, 'url', "/#{selectedItem.name}"
