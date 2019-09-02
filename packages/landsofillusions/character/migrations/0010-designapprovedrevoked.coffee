LOI = LandsOfIllusions
RS = Retronator.Store

class Migration extends Document.MajorMigration
  name: "Design approved revoked for custom characters."

  forward: (document, collection, currentSchema, newSchema) =>
    count = 0

    usersCollection = new DirectCollection 'users'

    collection.findEach
      _schema: currentSchema
      designApproved: true
      user: $ne: null
      'avatar.body.template': $exists: false
    ,
      (document) =>
        # Double check that the user has avatar editor, so they will actually be able to re-design their character.
        user = usersCollection.findOne _id: document.user._id

        hasPlayerAccess = _.find user.items, (item) => item.catalogKey is RS.Items.CatalogKeys.PixelArtAcademy.PlayerAccess
        hasAvatarEditor = _.find user.items, (item) => item.catalogKey is RS.Items.CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor

        # If a user currently has player access but not the avatar editor, give out a warning.
        # They probably lost avatar editor access somewhere along the way, so nothing is necessarily wrong.
        if hasPlayerAccess and not hasAvatarEditor
          console.warn "Player #{user.displayName} does not have the avatar editor, yet has custom characters."

        count += collection.update _id: document._id,
          $set:
            designApproved: false

    counts = super arguments...
    counts.migrated += count
    counts.all += count
    counts

LOI.Character.addMigration new Migration()
