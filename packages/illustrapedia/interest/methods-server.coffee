AB = Artificial.Babel
RA = Retronator.Accounts
IL = Illustrapedia

IL.Interest.insert.method (initialData) ->
  check initialData, Match.OptionalOrNull Object
  RA.authorizeAdmin()

  initialData ?= {}

  # Create translation for the name.
  initialData.name ?=
    _id: AB.Translation.documents.insert {}

  IL.Interest.documents.insert initialData

IL.Interest.update.method (id, modifier) ->
  check id, Match.DocumentId
  check modifier, Object
  RA.authorizeAdmin()

  IL.Interest.documents.update id, modifier
