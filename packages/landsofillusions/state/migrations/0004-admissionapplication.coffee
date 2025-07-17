LOI = LandsOfIllusions

class Migration extends Document.MinorMigration
  name: "Move admission application to read-only state and schedule admission email."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    usersCollection = if Meteor.isClient then Retronator.Accounts.User.documents else new DirectCollection 'users'
    charactersCollection = if Meteor.isClient then LOI.Character.documents else new DirectCollection 'LandsOfIllusions.Characters'

    collection.findEach
      _schema: currentSchema
      'state.things.PixelArtAcademy.Season1.Episode1.Chapter1.AdmissionWeek.applied': true
    ,
      (document) =>
        readOnlyState = document.readOnlyState or {}

        # Set the applied field on the application state.
        _.nestedProperty readOnlyState, "things.PixelArtAcademy.Season1.Episode1.Chapter1.application.applied", true
      
        # Set the date.
        _.nestedProperty readOnlyState, "things.PixelArtAcademy.Season1.Episode1.Chapter1.application.applicationTime", 0
        _.nestedProperty readOnlyState, "things.PixelArtAcademy.Season1.Episode1.Chapter1.application.applicationRealTime", Date.now()
        
        events = document.events or []

        # See if user has alpha access.
        character = charactersCollection.findOne _id: document.character._id

        skipAddEvent = false

        unless character
          console.warn "Game state #{document._id} didn't have a valid character #{document.character._id}"

        unless character?.user
          console.warn "Game state #{document._id} didn't have an active character #{document.character._id}"

        unless skipAddEvent
          user = usersCollection.findOne
            _id: character?.user?._id
            'items.catalogKey': 'PixelArtAcademy.AlphaAccess'

        if user
          event = _.find events, (event) -> event.type is "PixelArtAcademy.Season1.Episode1.Chapter1.Events.ApplicationAccepted"

          if event
            console.warn "Game state #{document._id} already has the application accepted event."

          else
            events.push
              type: "PixelArtAcademy.Season1.Episode1.Chapter1.Events.ApplicationAccepted"
              gameTime: 0.375
              id: Random.id()

        else
          "Processed applied character #{document.character._id} without alpha access."

        updated = collection.update
          _id: document._id
        ,
          $set:
            readOnlyState: readOnlyState
            events: events
            _schema: newSchema

        count += updated

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.GameState.addMigration new Migration()
