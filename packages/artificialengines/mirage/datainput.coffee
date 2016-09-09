AM = Artificial.Mirage

class Artificial.Mirage.DataInputComponent extends AM.Component
  template: ->
    'Artificial.Mirage.DataInputComponent'

  constructor: ->
    super

    @type = 'text'

    @persistent = true
    @realtime = true
    @autoSelect = false
    @autoResizeTextarea = false

  mixins: ->
    mixins = []
    mixins.push AM.AutoSelectInputMixin if @autoSelect
    mixins.push AM.PersistentInputMixin if @persistent
    mixins.push AM.AutoResizeTextareaMixin if @autoResizeTextarea
    mixins

  isTextarea: ->
    @type is 'textarea'

  load: ->
    console.error "You must implement the load method."

  save: (value) ->
    console.error "You must implement the save method."

  value: ->
    # We do the comparison with ? since we want to preserve empty strings '' (or would not).
    @callFirstWith(@, 'value') ? @load()

  placeholder: ->
    @callFirstWith(@, 'placeholder')

  events: -> [
    'change input, change textarea': @onChange
    'input input, input textarea': @onInput
  ]

  onChange: (event) ->
    @save $(event.target).val() unless @realtime

  onInput: (event) ->
    @save $(event.target).val() if @realtime
