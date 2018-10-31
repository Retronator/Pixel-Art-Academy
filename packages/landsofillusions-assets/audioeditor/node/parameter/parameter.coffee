AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Assets.AudioEditor.Node.Parameter extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.AudioEditor.Node.Parameter'
  @register @id()
  
  constructor: (@options) ->
    super arguments...

  onCreated: ->
    super arguments...

    # Show a direct data input if we have a pattern.
    if @options.pattern
      @dataInput = new @constructor.DataInput @options

  class @DataInput extends AM.DataInputComponent
    @register 'LandsOfIllusions.Assets.AudioEditor.Node.Parameter.DataInput'

    # Note: We can't simply call the variable @options since the
    # data input component uses that for values of a select input.
    constructor: (@dataInputOptions) ->
      super arguments...

      if @dataInputOptions.options
        @type = AM.DataInputComponent.Types.Select

      else if @dataInputOptions.pattern() is String
        @type = AM.DataInputComponent.Types.Text

    options: ->
      options = for option in @dataInputOptions.options
        name: option
        value: option
        
      unless @dataInputOptions.default
        options.unshift
          name: ''
          value: null

      options

    load: ->
      @dataInputOptions.load() or @dataInputOptions.default

    save: (value) ->
      @dataInputOptions.save value
