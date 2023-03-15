AM = Artificial.Mummification

Document.startup ->
  AM.DatabaseContent.directoryUrl = "databasecontent/directory.json"

  # Don't import if we're starting empty.
  return if Meteor.settings.startEmpty

  # Database content is active only when any export getters were registered.
  return unless AM.DatabaseContent.exportGetters.length

  # Try to retrieve the database content directory.
  directoryJson = AM.DatabaseContent.assets.getText AM.DatabaseContent.directoryUrl

  # Note: We need to parse with EJSON instead of using result.data (which
  # is parsed with JSON) to get date objects properly reconstructed.
  directory = EJSON.parse directoryJson
  AM.DatabaseContent.import directory
