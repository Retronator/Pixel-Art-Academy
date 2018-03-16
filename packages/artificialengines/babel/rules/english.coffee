AB = Artificial.Babel

class AB.Rules.English
  @createPossessive: (noun) ->
    if _.last(noun) is 's'
      "#{noun}'"
      
    else
      "#{noun}'s"
