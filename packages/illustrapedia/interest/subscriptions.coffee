RA = Retronator.Accounts
IL = Illustrapedia

IL.Interest.all.publish ->
  RA.authorizeAdmin()
  
  IL.Interest.getPublishingDocuments().find()
  
IL.Interest.forReferenceNames.publish (referenceNames) ->
  check referenceNames, [String]
  
  IL.Interest.getPublishingDocuments().find
    'referenceName': $in: referenceNames

IL.Interest.forSearchTerm.publish (searchTerm) ->
  check searchTerm, String

  IL.Interest.forSearchTerm.query searchTerm, true
