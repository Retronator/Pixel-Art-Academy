RA = Retronator.Accounts
LOI = LandsOfIllusions

# Subscription to a specific sprite.
LOI.Assets.Sprite.forId.publish (id) ->
  check id, Match.DocumentId

  LOI.Assets.Sprite.documents.find id

LOI.Assets.Sprite.all.publish ->
  # Only admins (and later sprite editors) can see all the sprite.
  RA.authorizeAdmin userId: @userId or null

  # We only return sprite names when subscribing to all so that we can list them.
  LOI.Assets.Sprite.documents.find {},
    fields:
      name: 1

LOI.Assets.Sprite.forCharacterPartTemplatesOfTypes.publish (types) ->
  check types, [String]

  templates = LOI.Character.Part.Template._forTypes(types, @userId).fetch()
  findSpritesInCharacterPartTemplates templates

LOI.Assets.Sprite.forCharacterPartTemplatesOfCurrentUser.publish ->
  templates = LOI.Character.Part.Template._forUserId(@userId).fetch()

  findSpritesInCharacterPartTemplates templates

findSpritesInCharacterPartTemplates = (templates) ->
  spriteIds = _.flatten (template.spriteIds for template in templates)

  LOI.Assets.Sprite.documents.find
    _id:
      $in: spriteIds
