Template.registerHelper 'fixedDecimals', (value, numberOfDecimals) ->
  return unless _.isNumber value
  return unless _.isNumber numberOfDecimals

  value.toFixed numberOfDecimals
  
Template.registerHelper 'roundNumber', (value) ->
  return unless _.isNumber value
  
  Math.round value
