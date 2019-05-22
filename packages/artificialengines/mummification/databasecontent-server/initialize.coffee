AM = Artificial.Mummification

Request = request

Document.prepare ->
  return if Meteor.settings.startEmpty

  # Database content is active only when any export getters were registered.
  return unless AM.DatabaseContent.exportGetters.length

  # Try to retrieve the database content directory.
  directoryUrl = Meteor.absoluteUrl "databasecontent/directory.json"
  Request.get directoryUrl, encoding: null, (error, response, body) ->
    return unless _.startsWith response.headers['content-type'], 'application/json'

    directory = EJSON.parse body.toString()
    AM.DatabaseContent.import directory
