_.mixin
  # Calls a property function until we end up with a value.
  propertyValue: (property) ->
    property = property() while _.isFunction property
    
    property
