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
    @bufferNumber = new ReactiveField null
    @_selectNextBufferNumber()
    
    # Reactively select a different buffer if it's not selected yet or the current one becomes unavailable
    # or select is triggered. We want to minimize re-selection so we create a computed field for it.
    @shouldSelectNextBufferNumber = new ComputedField =>
      @bufferNumber()? and @selectedBuffer()? and not @readInput('select')
    ,
      true
    
    @autorun (computation) =>
      return unless @shouldSelectNextBufferNumber()
      
      Tracker.nonreactive => @_selectNextBufferNumber()
      
    # Reactively recompute remaining buffer numbers when parameters change.
    @autorun (computation) =>
      @_recalculateRemainingBufferNumbers()
      
      # Update buffer number if it's not set to an active value.
      Tracker.nonreactive =>
        return if @bufferNumber()
        @_selectNextBufferNumber()
      
    @selectedBuffer = new ComputedField =>
      @readParameter "buffer#{@bufferNumber()}"
    ,
      (a, b) => a is b
    ,
      true
    
  destroy: ->
    super arguments...
    
    @shouldSelectNextBufferNumber.stop()
    @selectedBuffer.stop()
    
  _selectNextBufferNumber: ->
    # Select the last from the remaining numbers.
    remainingBufferNumbers = @remainingBufferNumbers()
    return unless remainingBufferNumbers.length
    
    nextBufferNumber = remainingBufferNumbers.pop()
    @bufferNumber nextBufferNumber
    
    # Update remaining numbers for next selection.
    if remainingBufferNumbers.length > 0
      @remainingBufferNumbers remainingBufferNumbers
      
    else
      @_recalculateRemainingBufferNumbers()
    
  _recalculateRemainingBufferNumbers: ->
    availableNumbers = []
    
    for i in [1..@constructor.maxBuffersCount]
      availableNumbers.push i if @readParameter "buffer#{i}"
      
    if availableNumbers.length > 1
      _.pull availableNumbers, Tracker.nonreactive => @bufferNumber()
      availableNumbers = _.shuffle availableNumbers
    
    @remainingBufferNumbers availableNumbers
  
  getReactiveValue: (output) ->
    return super arguments... unless output is 'buffer'
    
    @selectedBuffer
