AM = Artificial.Mummification

# Mongo collection with convenience functionality.
class AM.Collection extends Mongo.Collection
  constructor: (@name, options) ->
    super arguments...
  
  fetch: ->
    @find(arguments...).fetch()

  # Support for migrations (mimics DirectCollection)
  
  findEach: (selector, options, eachCallback) =>
    if _.isFunction options
      eachCallback = options
      options = {}
    options = {} unless options
    
    cursor = @find(selector, options)
    cursor.forEach eachCallback
