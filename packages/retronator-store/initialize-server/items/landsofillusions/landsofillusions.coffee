RA = Retronator.Accounts
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

Document.startup ->
  return if Meteor.settings.startEmpty

  # AVATARS

  RS.Item.create
    catalogKey: CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
    name: "Lands of Illusions — Character editor"
    description: "Create your own character by customizing body and portrait parts. This feature will be developed later and will unlock when it's ready." # TODO: change to "It's also great for social media profile pictures."

  RS.Item.create
    catalogKey: CatalogKeys.LandsOfIllusions.Character.Avatar.CustomItem
    name: "Lands of Illusions — Custom character item"
    description: "Character item request for you and others to use, based on a photo you send."

  RS.Item.create
    catalogKey: CatalogKeys.LandsOfIllusions.Character.Avatar.UniqueItem
    name: "Lands of Illusions — Unique character item"
    description: "Custom character item available ONLY TO YOU, based on a photo you send."

  RS.Item.create
    catalogKey: CatalogKeys.LandsOfIllusions.Character.Avatar.UniqueCustomAvatar
    name: "Lands of Illusions — Custom character"
    description: "A full unique character and portrait fitted to your desires."
