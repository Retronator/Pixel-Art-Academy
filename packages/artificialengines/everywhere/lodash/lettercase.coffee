# String operations that change letter case.

_.mixin
  # Converts a string like "title case" to "Title Case"
  titleCase: (string) ->
    string.replace /\w\S*/g, (text) ->
      text.charAt(0).toUpperCase() + text.substr(1)
