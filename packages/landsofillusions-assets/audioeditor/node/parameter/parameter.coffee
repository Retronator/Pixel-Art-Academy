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

    if _.isArray @options.pattern
      # Enable editing an array of data inputs.
      @arrayOptions = new ComputedField =>
        arrayOptions = []

        # Get current array value. We need to clone it so we can manipulate it later.
        array = _.cloneDeep @options.load() or []

        # Prepare parameter options for all array elements and one extra.
        for arrayValue, index in array.concat null
          do (arrayValue, index) =>
            arrayOptions.push _.extend {}, @options,
              pattern: @options.pattern[0]
              load: => arrayValue
              save: (value) =>
                # See if we got a valid value (empty string represents null).
                if value is '' or not value?
                  # Remove the value.
                  array.splice index, 1

                else
                  # Update the value.
                  array[index] = value

                # Report new array value upstream.
                @options.save array

        arrayOptions

    # Note: Match objects have a pattern field on themselves.
    else if @options.pattern?.pattern or _.isFunction @options.pattern
      # Show a single data input.
      @dataInput = new @constructor.DataInput @options

    else if _.isObject @options.pattern      
      # Enable editing a map of data inputs.
      @objectValues = true

  class @DataInput extends AM.DataInputComponent
    @register 'LandsOfIllusions.Assets.AudioEditor.Node.Parameter.DataInput'

    # Note: We can't simply call the variable @options since the
    # data input component uses that for values of a select input.
    constructor: (@dataInputOptions) ->
      super arguments...

      # Minimize undo/redo history.
      @realtime = false

      if @dataInputOptions.options
        @type = AM.DataInputComponent.Types.Select

      else
        pattern = @dataInputOptions.pattern

        loop
          if pattern is Boolean
            @type = AM.DataInputComponent.Types.Checkbox

          else if pattern is Number
            @type = AM.DataInputComponent.Types.Number
            @customAttributes =
              step: @dataInputOptions.step
              min: @dataInputOptions.min
              max: @dataInputOptions.max

          else if pattern is String
            @type = AM.DataInputComponent.Types.Text

          # See if we can go deeper into the pattern.
          if pattern.pattern
            pattern = pattern.pattern

          else if pattern.choices
            pattern = pattern.choices[0]

          else
            break

    options: ->
      options = for option in @dataInputOptions.options
        if _.isObject option
          _.clone option

        else
          name: option
          value: option

      if @dataInputOptions.showValuesInDropdown
        currentValue = @load()

        # Change display text to value for all but chosen option.
        for option in options when option.value isnt currentValue
          option.name = option.value

      unless @dataInputOptions.default
        options.unshift
          name: ''
          value: null

      options

    load: ->
      @dataInputOptions.load()

    save: (value) ->
      if @type is AM.DataInputComponent.Types.Number
        if value
          value = parseFloat value

        else
          value = null

      @dataInputOptions.save value
