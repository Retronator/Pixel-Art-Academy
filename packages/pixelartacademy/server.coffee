# Rerun all generated fields when server starts. Remove in the future if this slows down server startup.
Meteor.startup ->
  Document.updateAll()
