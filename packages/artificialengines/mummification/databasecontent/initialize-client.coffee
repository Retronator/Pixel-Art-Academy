AM = Artificial.Mummification

Document.startup ->
  # Retrieve the database content directory.
  HTTP.get "/#{AM.DatabaseContent.directoryUrl}", (error, response) ->
    if error
      console.error error
      return
  
    return unless _.startsWith response.headers['content-type'], 'application/json'
    
    directory = EJSON.parse response.content
    AM.DatabaseContent.initialize directory
