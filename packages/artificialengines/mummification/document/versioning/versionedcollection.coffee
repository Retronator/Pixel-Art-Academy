AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mummification

class AM.Document.Versioning.VersionedCollection
  constructor: (@documentClass) ->
    @latestHistoryCollectionName = "#{@documentClass.id()}.latestHistory"
    @latestHistoryDocuments = new Mongo.Collection @latestHistoryCollectionName
