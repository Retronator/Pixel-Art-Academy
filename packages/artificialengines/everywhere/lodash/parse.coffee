_.mixin
  # Parses an int from a string or returns null if no integer can be parsed.
  parseIntOrNull: (string) ->
    int = parseInt string

    if _.isNaN int then null else int

  parseIntOrZero: (string) ->
    int = parseInt string

    if _.isNaN int then 0 else int

  # Parses a float from a string or returns null if no float can be parsed.
  parseFloatOrNull: (string) ->
    float = parseFloat string

    if _.isNaN float then null else float

  parseFloatOrZero: (string) ->
    float = parseFloat string

    if _.isNaN float then 0 else float
