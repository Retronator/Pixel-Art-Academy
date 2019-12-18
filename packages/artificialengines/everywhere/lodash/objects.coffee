_.mixin
  # Returns a property, either defined as a direct value or a function.
  propertyValue: (target, propertyName) ->
    return target[propertyName]() if _.isFunction target[propertyName]

    target[propertyName]
