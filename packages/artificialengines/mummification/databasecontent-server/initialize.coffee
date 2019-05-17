Request = request

Document.prepare ->
  return # if Meteor.settings.startEmpty

  # See if we have a database content folder.
  databaseContentUrl = Meteor.absoluteUrl "databasecontent/databasecontent.json"
  databaseContentResponse = Request.getSync databaseContentUrl, encoding: null

  return unless _.startsWith databaseContentResponse.response.headers['content-type'], 'application/json'

  databaseContent = JSON.parse databaseContentResponse.body.toString()

  LOI.DatabaseContent.import databaseContent
