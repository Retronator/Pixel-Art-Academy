LOI = LandsOfIllusions

class LOI.Assets.Engine.Audio.BiquadFilter extends LOI.Assets.Engine.Audio.Node
  @type: -> 'LandsOfIllusions.Assets.Engine.Audio.BiquadFilter'
  @nodeName: -> 'Biquad Filter'

  @Types:
    LowPass: 'lowpass'
    HighPass: 'highpass'
    BandPass: 'bandpass'
    LowShelf: 'lowshelf'
    HighShelf: 'highshelf'
    Peaking: 'peaking'
    Notch: 'notch'
    AllPass: 'allpass'

  @initialize()

  @inputs: -> [
    name: 'in'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Channels
  ]

  @outputs: -> [
    name: 'out'
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Channels
  ]

  @parameters: -> [
    name: 'type'
    pattern: String
    options: _.values @Types
    default: @Types.LowPass
    type: LOI.Assets.Engine.Audio.ConnectionTypes.ReactiveValue
  ,
    name: 'frequency'
    pattern: Match.OptionalOrNull Number
    default: 350
    min: 10
    max: 24000
    step: 10
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Parameter
  ,
    name: 'detune'
    pattern: Match.OptionalOrNull Number
    default: 0
    step: 100
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Parameter
  ,
    name: 'Q'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 1
    min: 0.0001
    max: 1000
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Parameter
  ,
    name: 'gain'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 0
    min: -40
    max: 40
    type: LOI.Assets.Engine.Audio.ConnectionTypes.Parameter
  ]

  constructor: ->
    super arguments...

    @node = new ComputedField =>
      return unless audioManager = @audioManager()
      return unless audioManager.contextValid()
      
      audioManager.context.createBiquadFilter()

    @filterUpdatedDependency = new Tracker.Dependency

    @autorun (computation) =>
      return unless node = @node()

      node.type = @readParameter 'type'
      node.frequency.value = @readParameter 'frequency'
      node.detune.value = @readParameter 'detune'
      node.Q.value = @readParameter 'Q'
      node.gain.value = @readParameter 'gain'

      @filterUpdatedDependency.changed()

  getDestinationConnection: (input) ->
    empty = super arguments...

    switch input
      when 'in'
        destination: @node()

      when 'frequency'
        destination: @node()?.frequency

      when 'detune'
        destination: @node()?.detune

      when 'Q'
        destination: @node()?.Q

      when 'gain'
        destination: @node()?.gain

      else
        empty

  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'

    source: @node()
