AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Node.BiquadFilter extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.Node.BiquadFilter'
  @register @id()

  @_frequenciesBase = 1.07

  @frequencies = for index in [0..99]
    24000 / Math.pow @_frequenciesBase, 99 - index

  @_frequencies = new Float32Array @frequencies
  @_magnitudeResponse = new Float32Array 100
  @_phaseResponse = new Float32Array 100

  constructor: (@node) ->
    super arguments...

  onCreated: ->
    super arguments...

    @audioNode = new ComputedField => 
      return unless audio = @node.audioCanvas.audioEditor.audio()
      audio.getNode @node.id

  onRendered: ->
    super arguments...

    # Draw the filter response.
    @autorun (computation) =>
      canvas = @$('.frequency-response-canvas')[0]
      context = canvas.getContext '2d'

      context.clearRect 0, 0, 100, 50
      context.lineWidth = 1

      if audioNode =  @audioNode()
        # Depend on filter updates.
        audioNode.filterUpdatedDependency.depend()

        if biquadFilterNode = audioNode.node()
          biquadFilterNode.getFrequencyResponse @constructor._frequencies, @constructor._magnitudeResponse, @constructor._phaseResponse

      # Draw phase response.
      context.strokeStyle = "#1c5c48"
      context.beginPath()

      context.moveTo 0, 25.5

      if biquadFilterNode
        for value, index in @constructor._phaseResponse
          context.lineTo index, 25.5 + value * 5

      context.lineTo 100, 25.5
      context.stroke()

      # Draw magnitude response.
      context.strokeStyle = "#7c8ce0"
      context.beginPath()

      context.moveTo 0, 25.5

      if biquadFilterNode
        for value, index in @constructor._magnitudeResponse
          context.lineTo index, (1 - value * 0.5) * 50.5

      context.lineTo 100, 25.5
      context.stroke()

      if audioNode
        # Draw frequency parameter.
        frequency = audioNode.readParameter 'frequency'
        detune = audioNode.readParameter 'detune'

        effectiveFrequency = frequency * Math.pow 2, detune / 1200
        x = 99.5 - Math.floor Math.log(24000 / effectiveFrequency) / Math.log @constructor._frequenciesBase

        context.strokeStyle = "#8c58b8"
        context.beginPath()

        context.moveTo x, 0
        context.lineTo x, 50
        context.stroke()

      canvas
