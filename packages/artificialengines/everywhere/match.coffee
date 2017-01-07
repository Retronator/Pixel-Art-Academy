# Match extensions

# Numbers

Match.Range = (min, max) ->
  check min, Number
  check max, Number

  Match.Where (value) ->
    check value, Number
    min < value < max

Match.IntegerRange = (min, max) ->
  check min, Match.Integer
  check max, Match.Integer

  Match.Where (value) ->
    check value, Match.Integer
    min < value < max

Match.NonNegativeNumber = Match.Where (value) ->
  check value, Number
  value >= 0

Match.PositiveInteger = Match.Where (value) ->
  check value, Match.Integer
  value > 0

Match.NonNegativeInteger = Match.Where (value) ->
  check value, Match.Integer
  value >= 0
