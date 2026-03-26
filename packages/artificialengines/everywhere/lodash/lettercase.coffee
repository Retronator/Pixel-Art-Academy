# String operations that change letter case.

_.mixin
  # Converts a string like "title case" to "Title Case"
  titleCase: (string) ->
    string.replace /\w\S*/g, (text) ->
      text.charAt(0).toUpperCase() + text.substr(1)

  # Converts a string like "pascal case" to "PascalCase"
  pascalCase: (string) ->
    camelCase = _.camelCase string
    camelCase.charAt(0).toUpperCase() + camelCase.substr(1)

  # Converts a string like "file case" to "filecase"
  fileCase: (string) ->
    camelCase = _.camelCase string
    camelCase.toLowerCase()
