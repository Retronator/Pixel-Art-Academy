Template.registerHelper 'capitalize', (string) ->
  _.capitalize string if string

Template.registerHelper 'toLower', (string) ->
  _.toLower string if string

Template.registerHelper 'toUpper', (string) ->
  _.toUpper string if string

Template.registerHelper 'deburr', (string) ->
  _.deburr string if string
