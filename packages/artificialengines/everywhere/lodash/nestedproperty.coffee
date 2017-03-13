# Access to properties on nested objects.

_.mixin
  # Gets or sets a property that can be on a nested object, specified with the dot notation.
  nestedProperty: (object, property, value) ->
    nestedObject = object
    parts = property.split '.'

    # Is this a setter? We compare to undefined and not just use
    # value? since we want to be able to set the value null to the property.
    if value isnt undefined
      # Setter that modifies object in-place and creates any intermediate objects.
      for part, i in parts
        # If we're already at the end just set the property and return the original object.
        if i is parts.length - 1
          nestedObject[part] = value
          return object

        else
          # We have to drop deeper. If nestedObject doesn't have the part property, create an empty object.
          nestedObject[part] ?= {}

          # Drop in if it is an actual object that we can drop into.
          throw new Meteor.Error 'invalid-argument', "Property does not address a nested property." unless _.isObject nestedObject[part]

          nestedObject = nestedObject[part]

    # Getter that returns undefined if hit with non-objects.
    for part in parts
      return undefined unless _.isObject nestedObject
      nestedObject = nestedObject[part]

    # We've dropped to the end so nestedObject should be the value of the desired property.
    nestedObject
