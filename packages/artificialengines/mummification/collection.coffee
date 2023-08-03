AM = Artificial.Mummification

# Mongo collection with convenience functionality.
class AM.Collection extends Mongo.Collection
  constructor: (@name, options) ->
    super arguments...
  
  fetch: ->
    @find(arguments...).fetch()
