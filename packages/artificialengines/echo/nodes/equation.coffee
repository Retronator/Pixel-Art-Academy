AEc = Artificial.Echo

class AEc.Node.Equation extends AEc.Node
  @type: -> 'Artificial.Echo.Node.Equation'
  @displayName: -> 'Equation'

  @initialize()
  
  @inputLetters = 'abcde'
  
  @inputs: -> for inputLetter in @inputLetters
    name: inputLetter
    type: AEc.ConnectionTypes.ReactiveValue

  @outputs: -> [
    name: 'value'
    type: AEc.ConnectionTypes.ReactiveValue
  ]

  @parameters: -> [
    name: 'equation'
    pattern: String
    type: AEc.ConnectionTypes.ReactiveValue
    valueType: AEc.ValueTypes.String
  ]
  
  @coffeeScriptReplacements =
    ' is ': ' == '
    ' isnt ': ' != '
    ' and ': ' && '
    ' or ': ' || '
    'not ': '!'
    
  constructor: ->
    super arguments...

    @value = new ComputedField =>
      return unless equation = @readParameter 'equation'

      code = ""
      
      for inputLetter in @constructor.inputLetters
        inputValue = @readParameter inputLetter
        code += "let #{inputLetter} = #{inputValue ? 'null'};"
    
      # Change CoffeeScript syntax to JavaScript.
      for word, replacement of @constructor.coffeeScriptReplacements
        equation = equation.replace new RegExp(word, 'g'), replacement
        
      code += equation
      
      try
        eval code
        
      catch error
        console.warn "Equation node error:", error.message
    ,
      true
    
  destroy: ->
    super arguments...
    
    @value.stop()

  getReactiveValue: (output) ->
    return super arguments... unless output is 'value'
    
    @value
