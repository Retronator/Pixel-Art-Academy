_.mixin
  # Creates a filter function out of a property, matcher, or function.
  # Code based on Blaze Components childComponentsWith.
  filterFunction: (propertyOrMatcherOrFunction) ->
    if _.isString propertyOrMatcherOrFunction
      property = propertyOrMatcherOrFunction
      propertyOrMatcherOrFunction = (data) =>
        property of data

    else unless _.isFunction propertyOrMatcherOrFunction
      assert _.isObject propertyOrMatcherOrFunction
      matcher = propertyOrMatcherOrFunction
      propertyOrMatcherOrFunction = (data) =>
        for property, value of matcher
          return false unless property of data

          if _.isFunction data[property]
            return false unless data[property]() is value

          else
            return false unless data[property] is value

        true

    propertyOrMatcherOrFunction
