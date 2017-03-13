_.mixin
  # Calls a property function until we end up with a value.
  propertyValue: (target, propertyName) ->
    return target[propertyName]() if _.isFunction target[propertyName]

    target[propertyName]
