LOI = LandsOfIllusions
PAA = PixelArtAcademy
Twit = Npm.require 'twit'

Meteor.methods
  getImgFromTweet: (id) ->
    if Meteor.settings.twitter
      @_tweet = new Twit
        consumer_key: Meteor.settings.twitter.consumerKey
        consumer_secret: Meteor.settings.twitter.secret
        app_only_auth: true

      @_tweetGetSync = Meteor.wrapAsync( @_tweet.get.bind @_tweet )

      apiUrl = 'statuses/show/' + id
      return @_tweetGetSync(apiUrl)

  "PixelArtAcademy.Practice.CheckIn.import": (characterId) ->
    check characterId, Match.DocumentId

    # Make sure the character belongs to the current user.
    authorizeCharacter characterId

    user = Meteor.user()

    # Try to match by registered emails.
    if user.registered_emails
      for email in user.registered_emails
        continue unless email.verified

        # Find the checkIns in imported data.
        importedCheckIns = PAA.Practice.ImportedData.CheckIn.documents.find(
          backerEmail: email.address
        ).fetch()

        console.log "Found", importedCheckIns.length, "check-ins for email", email.address

        Meteor.call 'practiceCheckIn', characterId, importedCheckIn.text, importedCheckIn.image, importedCheckIn.timestamp for importedCheckIn in importedCheckIns

authorizeCharacter = (characterId) ->
  currentUserId = Meteor.userId()

  # You need to be logged-in to perform actions with the character.
  throw new Meteor.Error 'unauthorized', "Unauthorized." unless currentUserId

  character = LOI.Accounts.Character.documents.findOne characterId
  throw new Meteor.Error 'not-found', "Character not found." unless character

  throw new Meteor.Error 'unauthorized', "Unauthorized." unless character.user._id is currentUserId
