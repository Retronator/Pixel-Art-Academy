AM = Artificial.Mirage

class Artificial.Mirage.AutoSelectInputMixin extends BlazeComponent
  events: -> [
    'focus input': @onFocus
  ]

  onFocus: (event) ->
    $(event.target).select()
