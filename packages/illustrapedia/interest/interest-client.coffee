AB = Artificial.Babel
AM = Artificial.Mummification
IL = Illustrapedia

class IL.Interest extends IL.Interest
  @Meta
    name: @id()
    replaceParent: true
    
  @enablePersistence()
  
  # Load cache.
  HTTP.get @cacheUrl, (error, response) ->
    if error
      console.error error
      return
    
    try
      documents = EJSON.parse response.content
      
      for document in documents
        IL.Interest.documents.insert document
    
    catch exception
      console.error exception
