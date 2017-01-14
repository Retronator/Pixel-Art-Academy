AM = Artificial.Mirage

# Prevents the input value to be overridden while editing.
class Artificial.Mirage.PersistentInputMixin extends BlazeComponent
  onCreated: ->
    @storedValue = new ReactiveField()

  value: ->
    @storedValue()

  events: -> [
    'focus input, focus textarea': @onFocus
    'blur input, blur textarea': @onBlur
  ]

  onFocus: (event) ->
    # Store the value in the input or an empty string in case the value is undefined (if we were to store undefined the
    # mixin wouldn't hold precedence over others and the value would be called from the parent or other mixins instead).
    @storedValue @mixinParent().value() or ''

  onBlur: (event) ->
    @storedValue null
