AM = Artificial.Mirage

# Selects the input text on focus.
class Artificial.Mirage.AutoSelectInputMixin extends BlazeComponent
  events: -> [
    'focus input': @onFocus
  ]

  onFocus: (event) ->
    $(event.target).select()
