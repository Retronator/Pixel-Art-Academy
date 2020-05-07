# Operations that deal with strings.

_.mixin
  # Same as padStart, but supports negative lengths.
  indent: (string, length) ->
    if length >= 0
      _.padStart string, length

    else
      # Make sure we only clear spaces.
      trimmedString = _.trimStart string
      spacesCount = string.length - trimmedString.length

      startingIndex = Math.min -length, spacesCount

      # Get the part of the string after the starting index.
      string[startingIndex..]

  outdent: (string, length) ->
    _.indent string, -length

  insertIntoString: (string, position, textToInsert) ->
    string.substring(0, position) + textToInsert + string.substring(position)
