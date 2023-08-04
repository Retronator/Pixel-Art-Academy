AEc = Artificial.Echo

class AEc.Node.RandomBuffer extends AEc.Node
  @type: -> 'Artificial.Echo.Node.RandomBuffer'
  @displayName: -> 'Random Buffer'

  @initialize()
  
  @inputs: -> [
    name: 'select'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Trigger
  ]
  
  @maxBuffersCount = 5
  
  @parameters: -> for i in [1..@maxBuffersCount]
    name: "buffer#{i}"
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Buffer
  
  @outputs: -> [
    name: 'buffer'
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.Buffer
  ]

  constructor: ->
    super arguments...
    
    @bufferNumber = new ReactiveField @_selectNextBufferNumber()
    
    # Reactively select a different buffer if it's not selected yet or the current one becomes unavailable or select is triggered.
    @autorun (computation) =>
      return if @bufferNumber()? and @selectedBuffer()? and not @readInput('select')
      
      @bufferNumber @_selectNextBufferNumber()
      
    @selectedBuffer = new ComputedField =>
      @readParameter "buffer#{@bufferNumber()}"
    ,
      (a, b) => a is b
    ,
      true
    
  destroy: ->
    super arguments...
    
    @selectedBuffer.destroy()
    
  _selectNextBufferNumber: ->
    availableNumbers = []
    
    for i in [1..@constructor.maxBuffersCount]
      availableNumbers.push i if @readParameter "buffer#{i}"
    
    availableNumbers[Math.floor Math.random() * availableNumbers.length]
  
  getReactiveValue: (output) ->
    return super arguments... unless output is 'buffer'
    
    @selectedBuffer
