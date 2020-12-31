AM = Artificial.Mirage

Template.registerHelper 'stringify', (object) ->
  EJSON.stringify object

Template.registerHelper 'random', (object) ->
  Random.id()
