AE = Artificial.Everywhere
AM = Artificial.Mirage

nullString = "_null"

# Base class for an input component with easy setup for different mixins.
class Artificial.Mirage.DataInputComponent extends AM.Component
  @Types:
    Text: 'text'
    TextArea: 'textarea'
    Select: 'select'
    Number: 'number'
    Checkbox: 'checkbox'
    Date: 'date'
    Range: 'range'
    Radio: 'radio'

  template: ->
    'Artificial.Mirage.DataInputComponent'

  constructor: ->
    super arguments...

    @type = @constructor.Types.Text

    @persistent = true
    @realtime = true
    @autoSelect = false
    @autoResizeTextarea = false

  onRendered: ->
    super arguments...

    # Set the value for the first time since some controls don't do it themselves.
    switch @type
      when @constructor.Types.Checkbox
        @$('input').prop 'checked', @value()
    
      when @constructor.Types.Radio
        @$("input[name=#{@name}][value=#{@value() ? nullString}]").prop 'checked', true
    
      else
        @$('input').val @value()

  mixins: ->
    mixins = []
    mixins.push AM.AutoSelectInputMixin if @autoSelect
    mixins.push AM.PersistentInputMixin if @persistent
    mixins.push AM.AutoResizeTextareaMixin if @autoResizeTextarea
    mixins

  isTextArea: ->
    @type is @constructor.Types.TextArea

  isSelect: ->
    @type is @constructor.Types.Select

  isCheckbox: ->
    @type is @constructor.Types.Checkbox
    
  isRadio: ->
    @type is @constructor.Types.Radio

  load: ->
    throw new AE.NotImplementedException "You must implement the load method."

  save: (value) ->
    throw new AE.NotImplementedException "You must implement the save method."

  value: ->
    # We do the comparison with ? since we want to preserve empty strings '' ('or' would not).
    @callFirstWith(@, 'value') ? @load()

  placeholder: ->
    @callFirstWith(@, 'placeholder')

  selectedAttribute: ->
    option = @currentData()
    selectedValue = @value()

    'selected' if option.value is selectedValue

  checkedAttribute: ->
    'checked' if @value()

  checkedRadioAttribute: ->
    option = @currentData()
    selectedValue = @value()
    
    'checked' if option.value is selectedValue
  
  nullable: (value) ->
    value ? nullString
    
  events: -> [
    'change input, change textarea': @onChange
    'blur input, blur textarea': @onBlur
    'input input, input textarea': @onInput
    'change select': @onChangeSelect
  ]

  onChange: (event) ->
    return if @realtime

    @_processChange event

  onBlur: (event) ->
    return if @realtime
    
    @_processChange event

  onInput: (event) ->
    return unless @realtime
    
    @_processChange event
  
  _processChange: (event) ->
    switch @type
      when @constructor.Types.Checkbox
        @save $(event.target).is(':checked')
        return
        
      when @constructor.Types.Radio
        @save @_convertValue @$("input[name=#{@name}]:checked").val()
        return
  
    @save @_convertValue $(event.target).val()

  onChangeSelect: (event) ->
    # Return the value of the option and the text.
    @save @_convertValue $(event.target).val()

  _convertValue: (value) ->
    return null if value is nullString
    
    # Do any conversions of type.
    switch @type
      when @constructor.Types.Number, @constructor.Types.Range
        value = parseFloat value

    value

# Also provide the functionality to Component to generate its
# own data component that embedded data inputs can inherit from.
AM.Component.initializeDataComponent = ->
  componentClass = @

  class @DataInputComponent extends AM.DataInputComponent
    onCreated: ->
      super arguments

      # Note: We cannot name this parentComponent since that is a function of the BaseComponent.
      @dataProviderComponent = @ancestorComponentOfType componentClass

      throw new AE.NotImplementedException "Embedded data input component must provide the property name it binds to." unless @propertyName

    load: ->
      @dataProviderComponent[@propertyName]()

    save: (value) ->
      @dataProviderComponent[@propertyName] value
