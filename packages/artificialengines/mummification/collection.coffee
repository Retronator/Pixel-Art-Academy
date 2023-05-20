AM = Artificial.Mummification

# Mongo collection with convenience functionality.
class AM.Collection extends Mongo.Collection
  fetch: ->
    @find(arguments...).fetch()
