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
    
    @remainingBufferNumbers = new ReactiveField []
    @bufferNumber = new ReactiveField @_selectNextBufferNumber()
    
    # Reactively select a different buffer if it's not selected yet or the current one becomes unavailable or select is triggered.
    @autorun (computation) =>
      return if @bufferNumber()? and @selectedBuffer()? and not @readInput('select')
      
      @bufferNumber Tracker.nonreactive => @_selectNextBufferNumber()
      
    # Reactively recompute remaining buffer numbers when parameters change.
    @autorun (computation) =>
      @_recalculateRemainingBufferNumbers()
      
      # Update buffer number if it's not set to an active value.
      Tracker.nonreactive =>
        return if @bufferNumber()
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
    remainingBufferNumbers = @remainingBufferNumbers()
    return unless remainingBufferNumbers.length
    
    nextBufferNumber = remainingBufferNumbers.pop()
    
    if remainingBufferNumbers.length > 0
      @remainingBufferNumbers remainingBufferNumbers
      
    else
      @_recalculateRemainingBufferNumbers()
    
    nextBufferNumber
    
  _recalculateRemainingBufferNumbers: ->
    availableNumbers = []
    
    for i in [1..@constructor.maxBuffersCount]
      availableNumbers.push i if @readParameter "buffer#{i}"
      
    if availableNumbers.length > 1
      _.pull availableNumbers, @bufferNumber()
      availableNumbers = _.shuffle availableNumbers
      
    @remainingBufferNumbers availableNumbers
  
  getReactiveValue: (output) ->
    return super arguments... unless output is 'buffer'
    
    @selectedBuffer
