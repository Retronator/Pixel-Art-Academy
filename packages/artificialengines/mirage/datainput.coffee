AE = Artificial.Everywhere
AM = Artificial.Mirage

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

  events: -> [
    'change input, change textarea': @onChange
    'input input, input textarea': @onInput
    'change select': @onChangeSelect
  ]

  onChange: (event) ->
    if @type is @constructor.Types.Checkbox
      @save $(event.target).is(':checked')
      return

    @save $(event.target).val() unless @realtime

  onInput: (event) ->
    @save $(event.target).val() if @realtime

  onChangeSelect: (event) ->
    # Return the value of the option and the text.
    @save $(event.target).val()
