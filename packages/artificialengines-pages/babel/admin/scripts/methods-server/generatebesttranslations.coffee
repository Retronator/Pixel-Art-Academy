AB = Artificial.Babel

Meteor.methods
  # For all users, call onTransactionsUpdated.
  'Artificial.Babel.Pages.Admin.Scripts.GenerateBestTranslations': ->
    Retronator.Accounts.authorizeAdmin()

    count = 0

    console.log "Generating best translations …"

    AB.Translation.documents.find().forEach (translation) ->
      translation.generateBestTranslations()
      count += AB.Translation.documents.update translation._id,
        $set:
          translations: translation.translations

    console.log "#{count} translations were processed."
