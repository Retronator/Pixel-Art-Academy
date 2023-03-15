AM = Artificial.Mummification
IL = Illustrapedia

Meteor.startup ->
  AM.DocumentCaches.add IL.Interest.cacheUrl, -> IL.Interest.documents.fetch()
