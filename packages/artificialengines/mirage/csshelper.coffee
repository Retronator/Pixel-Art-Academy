AM = Artificial.Mirage

class AM.CSSHelper
  @objectToString: (styleObject) ->
    propertyStrings = for camelCaseKey, value of styleObject
      key = camelCaseKey.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()

      # If a number was passed in, add the unit (except for certain CSS properties, as defined by jQuery)
      value += 'px' if typeof value is 'number' and not $.cssNumber[camelCaseKey]

      "#{key}: #{value};"

    propertyStrings.join ' '
