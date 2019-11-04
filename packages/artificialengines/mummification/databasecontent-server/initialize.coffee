AM = Artificial.Mummification

Document.startup ->
  return if Meteor.settings.startEmpty

  # Database content is active only when any export getters were registered.
  return unless AM.DatabaseContent.exportGetters.length

  # Try to retrieve the database content directory.
  directoryUrl = Meteor.absoluteUrl "databasecontent/directory.json"

  Artificial.Telepathy.RequestHelper.requestUntilSucceeded
    url: directoryUrl
    retryAfterSeconds: 60
    callback: (result) ->
      return unless _.startsWith result.headers['content-type'], 'application/json'

      # Note: We need to parse with EJSON instead of using result.data (which
      # is parsed with JSON) to get date objects properly reconstructed.
      directory = EJSON.parse result.content
      AM.DatabaseContent.import directory
