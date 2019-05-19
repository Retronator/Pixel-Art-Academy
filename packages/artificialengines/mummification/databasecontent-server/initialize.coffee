AM = Artificial.Mummification

Request = request

Document.prepare ->
  return if Meteor.settings.startEmpty

  # Database content is active only when any export getters were registered.
  return unless AM.DatabaseContent.exportGetters.length

  # Try to retrieve the database content descriptor.
  databaseContentUrl = Meteor.absoluteUrl "databasecontent/databasecontent.json"
  Request.get databaseContentUrl, encoding: null, (error, response, body) ->
    return unless _.startsWith response.headers['content-type'], 'application/json'

    databaseContent = JSON.parse body.toString()
    AM.DatabaseContent.import databaseContent
