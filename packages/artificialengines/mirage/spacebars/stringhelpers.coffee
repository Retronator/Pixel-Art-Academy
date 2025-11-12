Template.registerHelper 'capitalize', (string) ->
  _.capitalize string if string

Template.registerHelper 'titleCase', (string) ->
  _.titleCase string if string

Template.registerHelper 'kebabCase', (string) ->
  _.kebabCase string if string

Template.registerHelper 'toLower', (string) ->
  _.toLower string if string

Template.registerHelper 'toUpper', (string) ->
  _.toUpper string if string

Template.registerHelper 'upperFirst', (string) ->
  _.upperFirst string if string

Template.registerHelper 'deburr', (string) ->
  _.deburr string if string
