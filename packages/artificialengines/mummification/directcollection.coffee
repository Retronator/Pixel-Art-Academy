# Fix for DirectCollection on Mongo 3+.
DirectCollection::findEach = (selector, options, eachCallback) ->
  if _.isFunction options
    eachCallback = options
    options = {}
  options = {} unless options

  cursor = @_getCollection().find(selector, options)

  nextObject = blocking(cursor, cursor.next)

  while document = nextObject()
    eachCallback document

  return
