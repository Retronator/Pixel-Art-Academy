LOI = LandsOfIllusions

class Migration extends Document.PatchMigration
  name: "Set lastHangout time for your character to the study group join date if none is present."

  forward: (document, collection, currentSchema, newSchema) ->
    count = 0

    membershipCollection = new DirectCollection 'LandsOfIllusions.Character.Memberships'

    # For each study group member, check if they have the last hangout set.
    membershipCollection.findEach
      groupId: /PixelArtAcademy.Season1.Episode1.Chapter1.Groups.AdmissionsStudyGroup/
    ,
      (membershipDocument) =>
        # Find the game state for this character.
        characterId = membershipDocument.character._id
        gameStateDocument = collection.findOne 'character._id': characterId

        # See if the agent document is present.
        gameStateDocument.state.people = {} unless gameStateDocument.state.people
        gameStateDocument.state.people[characterId] = {} unless gameStateDocument.state.people[characterId]

        # If the agent has no last hangout, set it to their group join date.
        unless gameStateDocument.state.people[characterId].lastHangout
          gameStateDocument.state.people[characterId].lastHangout = time: membershipDocument.joinTime.getTime()

          updated = collection.update
            _id: gameStateDocument._id
          ,
            $set:
              'state.people': gameStateDocument.state.people
              _schema: newSchema

          count += updated

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.GameState.addMigration new Migration()
