# Operations that deal with strings.

_.mixin
  indent: (string, length) ->
    # Indent by the desired number of spaces.
    for i in [1..length]
      string = " #{string}"

    string

  outdent: (string, length) ->
    # Make sure we only clear spaces.
    trimmedString = _.trimStart string
    spacesCount = string.length - trimmedString.length

    startingIndex = Math.min length, spacesCount

    # Get the part of the string after the starting index.
    string[startingIndex..]

  insertIntoString: (string, position, textToInsert) ->
    string.substring(0, position) + textToInsert + string.substring(position)
