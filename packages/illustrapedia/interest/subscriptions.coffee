RA = Retronator.Accounts
IL = Illustrapedia

IL.Interest.all.publish ->
  RA.authorizeAdmin()
  
  IL.Interest.documents.find()

IL.Interest.forSearchTerm.publish (searchTerm) ->
  check searchTerm, String

  IL.Interest.forSearchTerm.query searchTerm
