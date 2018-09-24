RA = Retronator.Accounts
LOI = LandsOfIllusions

# Subscription to a specific mesh.
LOI.Assets.Mesh.forId.publish (id) ->
  check id, Match.DocumentId

  LOI.Assets.Mesh.documents.find id

LOI.Assets.Mesh.all.publish ->
  # Only admins (and later mesh editors) can see all the meshes.
  RA.authorizeAdmin userId: @userId or null

  # We only return mesh names when subscribing to all so that we can list them.
  LOI.Assets.Mesh.documents.find {},
    fields:
      name: 1
