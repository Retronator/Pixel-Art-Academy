RA = Retronator.Accounts
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

Meteor.startup ->
  # CHARACTERS

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.LandsOfIllusions.Character.Creation
    name: "Create a character"
    description: "You can create up to 10 characters to play in the world of Pixel Art Academy."

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarSelection
    name: "Character selection"
    description: "Select from one of the pre-made characters."

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
    name: "Character editor"
    description: "Create your character and portrait by choosing and customizing individual parts. Also great for social media profile pictures."

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
