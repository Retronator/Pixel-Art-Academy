RA = Retronator.Accounts
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

Meteor.startup ->
  # AVATARS

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
    name: "Character editor"
    description: "Create your own character by customizing body and portrait parts. It's also great for social media profile pictures."

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.LandsOfIllusions.Character.Avatar.CustomItem
    name: "Custom character item"
    description: "Character item request for you and others to use, based on a photo you send."

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.LandsOfIllusions.Character.Avatar.UniqueItem
    name: "Unique character item"
    description: "Custom character item available ONLY TO YOU, based on a photo you send."

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.LandsOfIllusions.Character.Avatar.UniqueCustomAvatar
    name: "Custom character"
    description: "A full unique character and portrait fitted to your desires."
