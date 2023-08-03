AEc = Artificial.Echo

class AEc.Node.BiquadFilter extends AEc.Node
  @type: -> 'Artificial.Echo.Node.BiquadFilter'
  @displayName: -> 'Biquad Filter'

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
    type: AEc.ConnectionTypes.Channels
  ]

  @outputs: -> [
    name: 'out'
    type: AEc.ConnectionTypes.Channels
  ]

  @parameters: -> [
    name: 'type'
    pattern: String
    options: _.values @Types
    default: @Types.LowPass
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.String
  ,
    name: 'frequency'
    pattern: Match.OptionalOrNull Number
    default: 350
    min: 10
    max: 24000
    step: 10
    type: AEc.ConnectionTypes.Parameter
  ,
    name: 'detune'
    pattern: Match.OptionalOrNull Number
    default: 0
    step: 100
    type: AEc.ConnectionTypes.Parameter
  ,
    name: 'Q'
    pattern: Match.OptionalOrNull Number
    step: 0.1
    default: 1
    min: 0.0001
    max: 1000
    type: AEc.ConnectionTypes.Parameter
  ,
    name: 'gain'
    pattern: Match.OptionalOrNull Number
    default: 0
    min: -40
    max: 40
    type: AEc.ConnectionTypes.Parameter
  ]

  constructor: ->
    super arguments...

    @node = new BiquadFilterNode @audio.context

    @filterUpdatedDependency = new Tracker.Dependency

    @autorun (computation) =>
      @node.type = @readParameter 'type'
      @node.frequency.value = @readParameter 'frequency'
      @node.detune.value = @readParameter 'detune'
      @node.Q.value = @readParameter 'Q'
      @node.gain.value = @readParameter 'gain'

      @filterUpdatedDependency.changed()

  getDestinationConnection: (input) ->
    empty = super arguments...

    switch input
      when 'in'
        destination: @node

      when 'frequency'
        destination: @node.frequency

      when 'detune'
        destination: @node.detune

      when 'Q'
        destination: @node.Q

      when 'gain'
        destination: @node.gain

      else
        empty

  getSourceConnection: (output) ->
    return super arguments... unless output is 'out'

    source: @node
