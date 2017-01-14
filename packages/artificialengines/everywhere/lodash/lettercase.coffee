# String operations that change letter case.

_.mixin
  # Converts a string like "title case" to "TitleCase"
  titleCase: (string) ->
    string.replace /\w\S*/g, (text) ->
      text.charAt(0).toUpperCase() + text.substr(1)

  # Converts a string like "camel case" to "camelCase"
  camelCase: (string) ->
    # Convert whole text (may include spaces) to title case.
    titleCase = _.titleCase string

    # Make first character lowercase.
    titleCase.charAt(0).toLowerCase() + titleCase.substr(1)

  # Converts a string like "string" or "STRING" to "String"
  capitalize: (string) ->
    string.charAt(0).toUpperCase() + string.substring(1).toLowerCase()
