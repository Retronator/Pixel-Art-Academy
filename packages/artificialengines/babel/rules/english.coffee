AB = Artificial.Babel

class AB.Rules.English
  @createPossessive: (noun) ->
    if _.last(noun) is 's'
      "#{noun}'"
      
    else
      "#{noun}'s"

  @createNounSeries: (nouns) ->
    return unless nouns
    
    switch nouns.length
      when 0 then ''
      when 1 then nouns[0]
      when 2 then "#{nouns[0]} and #{nouns[1]}"
      else
        nouns = _.clone nouns
        nouns[nouns.length - 1] = "and #{_.last nouns}"
        nouns.join ', '
