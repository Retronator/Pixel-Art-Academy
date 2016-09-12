# TODO: Upgrade to Retronator Accounts.

Meteor.methods
  'Retronator.Accounts.ImportedUsersEmailsToLowerCase': ->
    LOI.authorizeAdmin()

    LOI.Accounts.ImportedData.User.documents.find().forEach (document, index, cursor) ->
      importedUser = document
      lowerCaseEmail = importedUser.email.toLowerCase()
      return if importedUser.email is lowerCaseEmail

      console.log "Updating email", importedUser.email, "to lowercase", lowerCaseEmail
      LOI.Accounts.ImportedData.User.documents.update importedUser._id,
        $set:
          email: lowerCaseEmail
