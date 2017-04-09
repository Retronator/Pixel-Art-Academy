RA = Retronator.Accounts
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

Meteor.startup ->
  # Here we populate the store with all the items. Simple items are defined inline here, others
  # that have specific eligibility checking are their own classes that handle their creation.

  # PRE-ORDERS

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.PreOrder.BasicGame
    price: 10
    discountedFrom: 15
    name: "Pixel Art Academy - basic game pre-order"
    description: "Select from one of the pre-made characters and play through storylines, build your library of knowledge, complete assignments and track your art progress when the first episode launches in 2017. With a pre-order you also secure the lower price."
    items: [
      CatalogKeys.PixelArtAcademy.PlayerAccess
      CatalogKeys.PixelArtAcademy.FreshmanYear
    ]

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.PreOrder.FullGame
    price: 20
    discountedFrom: 25
    name: "Pixel Art Academy - full game pre-order"
    description: "Start playing once the first episode launches in 2017. You will be able to create your own character and portrait by choosing and customizing individual parts. As a pre-order bonus you enjoy the lower price and get the Retropolis Day Pass."
    items: [
      CatalogKeys.PixelArtAcademy.PlayerAccess
      CatalogKeys.PixelArtAcademy.FreshmanYear
      CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
      CatalogKeys.Retropolis.DayPass
    ]

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.PreOrder.AlphaAccess
    price: 40
    discountedFrom: 45
    name: "Pixel Art Academy - alpha access pre-order"
    description: "Get alpha access and start playing episodes in 2017 as soon as they enter alpha stage. You will be able to create your own character and portrait. Pre-ordering also gives you the lower price as well as the Retropolis Day and Nightlife Passes. This bundle is primarily if you want to support the project more."
    items: [
      CatalogKeys.PixelArtAcademy.PlayerAccess
      CatalogKeys.PixelArtAcademy.AlphaAccess
      CatalogKeys.PixelArtAcademy.FreshmanYear
      CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
      CatalogKeys.Retropolis.DayPass
      CatalogKeys.Retropolis.NightlifePass
    ]

  RS.Items.Bundles.PixelArtAcademyPreOrderAvatarEditorUpgrade.create()

  RS.Items.Bundles.PixelArtAcademyPreOrderAlphaAccessUpgrade.create()

  # KICKSTARTER TIERS

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.NoReward
    name: "Pixel Art Academy Kickstarter tier - No Reward"
    description: "You haven't chosen to receive a reward at the time of the Kickstarter. If you pledged enough to be able to get one of the three main tiers, you can use your store credit to purchase one now."
    items: []

  RS.Items.Bundles.PixelArtAcademyKickstarterBasicGame.create()

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.EarlyFullGame
    rewardId: 4292193
    name: "Pixel Art Academy Kickstarter tier - Early bird: YOUR OWN CHARACTER!"
    description: "Start playing once the game launches with Freshman Year 2017. You will be able to create your own character and portrait by choosing and customizing individual parts. I can already see it as your new Twitter avatar! The portrait (and your name) will also appear in a special section of the Retropolis Academy of Art Yearbook. I will also send you 50 backer updates with news from the development."
    items: [
      CatalogKeys.PixelArtAcademy.PlayerAccess
      CatalogKeys.PixelArtAcademy.AlphaAccess
      CatalogKeys.PixelArtAcademy.FreshmanYear
      CatalogKeys.PixelArtAcademy.SophomoreYear
      CatalogKeys.PixelArtAcademy.JuniorYear
      CatalogKeys.PixelArtAcademy.SeniorYear
      CatalogKeys.PixelArtAcademy.Kickstarter.GreenKeycard
      CatalogKeys.PixelArtAcademy.Kickstarter.RetropolisAcademyOfArtYearbook
      CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
    ]

  RS.Items.Bundles.PixelArtAcademyKickstarterFullGame.create()

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.EarlyAlphaAccess
    rewardId: 4292194
    name: "Pixel Art Academy Kickstarter tier - Early bird: GAME ALPHA!"
    description: "Get access to the alpha version and be part of the Foundation Year 2016, before the game publicly starts with Freshmen Year 2017. You will be able to create your own character and portrait, plus the character will appear in a special Class of 2016 Photo, an epic pixel artwork of the main campus quad with all your Foundation Year classmates. The portrait (and your name) will also appear in the Retropolis Academy of Art Yearbook as one of its first students. I will also send you 50 backer updates introducing new features in the alpha version."
    items: kickstarterAlphaItemsWith [
      CatalogKeys.PixelArtAcademy.Kickstarter.MagentaKeycard
    ]

  RS.Items.Bundles.PixelArtAcademyKickstarterAlphaAccess.create()

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.AvatarTrack.CustomItem
    rewardId: 4291886
    name: "Pixel Art Academy Kickstarter tier - Avatar track: CUSTOM ITEM!"
    description: "Start playing early with the alpha version and be part of the Foundation Year 2016. You will be able to create your own character and portrait, plus you will be able to request one item based on a photograph you provide. Others will also be able to use this item, so this could be a sneaky way of getting a sponsored item into the game.\n
                  Your character (with your new item) will appear in a special Class of 2016 Photo, an epic pixel artwork of all Foundation Year classmates. The portrait (and your name) will also appear in the Retropolis Academy of Art Yearbook as one of its prominent first students. I will also send you 50 backer updates introducing new features in the alpha version.\n
                  Note: custom items will be produced over the whole Foundation Year, but it will be ready at least before the final class photo is taken."
    items: kickstarterAlphaItemsWith [
      CatalogKeys.PixelArtAcademy.Kickstarter.RedKeycard
      CatalogKeys.LandsOfIllusions.Character.Avatar.CustomItem
    ]

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.AvatarTrack.UniqueItem
    rewardId: 4291887
    name: "Pixel Art Academy Kickstarter tier - Avatar track: UNIQUE ITEM!"
    description: "Start playing early with the alpha version and be part of the Foundation Year 2016. You will be able to create your own character and portrait, plus I will create an exclusive item for you based on a photograph you provide. Nobody else will be able to use it in the character editor!\n
                  Your character (with your exclusive item) will appear in a special Class of 2016 Photo, an epic pixel artwork of all Foundation Year classmates. The portrait (and your name) will also appear in the Retropolis Academy of Art Yearbook as one of its prominent first students. I will also send you 50 backer updates introducing new features in the alpha version.\n
                  Note: custom items will be produced over the whole Foundation Year, but it will be ready at least before the final class photo is taken."
    items: kickstarterAlphaItemsWith [
      CatalogKeys.PixelArtAcademy.Kickstarter.BlueKeycard
      CatalogKeys.LandsOfIllusions.Character.Avatar.UniqueItem
    ]

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.AvatarTrack.UniqueCustomAvatar
    rewardId: 4291888
    name: "Pixel Art Academy Kickstarter tier - Avatar track: UNIQUE CUSTOM AVATAR!"
    description: "Start playing early with the alpha version and be part of the Foundation Year 2016. I will create a whole custom character and portrait based on a photo and your desires! This is the best way if you want to play through the game as a pirate with a peg-leg and a parrot. Or a robot. As long as it is a humanoid and can fit through doors.\n
                  Your custom character will appear in a special Class of 2016 Photo, an epic pixel artwork of all Foundation Year classmates. The portrait (and your name) will also appear in the Retropolis Academy of Art Yearbook as one of its most important first students. I will also send you 50 backer updates introducing new features in the alpha version.\n
                  Note: your custom character will be created sometime during the whole Foundation Year, but it will be ready at least before the final class photo is taken. Before then you will create your own character like other players."
    items: kickstarterAlphaItemsWith [
      CatalogKeys.PixelArtAcademy.Kickstarter.BlackKeycard
      CatalogKeys.LandsOfIllusions.Character.Avatar.UniqueCustomAvatar
    ]

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.ArtistTrack.ClassHelp
    rewardId: 4291889
    name: "Pixel Art Academy Kickstarter tier - Artist track: CLASS HELP!"
    description: "Start playing early with the alpha version and be part of the Foundation Year 2016. Anywhere along the way you can request help on an assignment or general art guidance. I will write you detailed feedback on your artwork and steps to take in the future.\n
           In the game, you will be able to create your own character and portrait, plus the character will appear in a special Class of 2016 Photo, an epic pixel artwork of all Foundation Year classmates. The portrait (and your name) will also appear in the Retropolis Academy of Art Yearbook as one of its prominent first students. I will also send you 50 backer updates introducing new features in the alpha version."
    items: kickstarterAlphaItemsWith [
      CatalogKeys.PixelArtAcademy.Kickstarter.RedKeycard
      CatalogKeys.PixelArtAcademy.Help.ClassHelp
    ]

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.ArtistTrack.Paintover
    name: "Pixel Art Academy Kickstarter tier - Artist track: PAINTOVER!"
    rewardId: 4291890
    description: "Start playing early with the alpha version and be part of the Foundation Year 2016. Anywhere along the way you can request a paintover of one of your artwork. I will accompany it with detailed feedback and general art guidance.\n
                  In the game, you will be able to create your own character and portrait, plus the character will appear in a special Class of 2016 Photo, an epic pixel artwork of all Foundation Year classmates. The portrait (and your name) will also appear in the Retropolis Academy of Art Yearbook as one of its prominent first students. I will also send you 50 backer updates introducing new features in the alpha version."
    items: kickstarterAlphaItemsWith [
      CatalogKeys.PixelArtAcademy.Kickstarter.BlueKeycard
      CatalogKeys.PixelArtAcademy.Help.Paintover
    ]

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.ArtistTrack.PaintoverVideo
    rewardId: 4291891
    name: "Pixel Art Academy Kickstarter tier - Artist track: PAINTOVER VIDEO!"
    description: "Start playing early with the alpha version and be part of the Foundation Year 2016. Anywhere along the way you can request a paintover of one of your artwork and I will create a video detailing my changes and the art lessons contained within. I will also write you general art guidance for meeting your own goals.\n
                  In the game, you will be able to create your own character and portrait, plus the character will appear in a special Class of 2016 Photo, an epic pixel artwork of all Foundation Year classmates. The portrait (and your name) will also appear in the Retropolis Academy of Art Yearbook as one of its prominent first students. I will also send you 50 backer updates introducing new features in the alpha version."
    items: kickstarterAlphaItemsWith [
      CatalogKeys.PixelArtAcademy.Kickstarter.BlackKeycard
      CatalogKeys.PixelArtAcademy.Help.PaintoverVideo
    ]

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.ArtCollector.ZXCosmopolis
    rewardId: 4291892
    name: "Pixel Art Academy Kickstarter tier - Art collector: ZX COSMOPOLIS!"
    description: "Get a huge 44'' unique signed canvas print of ZX Cosmopolis from my personal collection.\n
                  Also includes the UNIQUE CUSTOM AVATAR!\n
                  Start playing early with the alpha version and be part of the Foundation Year 2016. I will create a whole custom character and portrait based on a photo and your desires! Your custom character will appear in a special Class of 2016 Photo, an epic pixel artwork of all Foundation Year classmates. The portrait (and your name) will also appear in the Retropolis Academy of Art Yearbook as one of its most important first students. I will also send you 50 backer updates introducing new features in the alpha version.\n
                  Note: your custom character will be created sometime during the whole Foundation Year, but it will be ready at least before the final class photo is taken. Before then you will create your own character like other players."
    items: kickstarterAlphaItemsWith [
      CatalogKeys.PixelArtAcademy.Kickstarter.ZXBlackKeycard
      CatalogKeys.PixelArtAcademy.Kickstarter.ZXCosmopolis
      CatalogKeys.LandsOfIllusions.Character.Avatar.UniqueCustomAvatar
    ]

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.ArtCollector.PixelChinaMountains
    rewardId: 4292042
    name: "Pixel Art Academy Kickstarter tier - Art collector: PIXEL CHINA MOUNTAINS!"
    description: "Get a huge 44'' unique signed canvas print of Pixel China Mountains from my personal collection.\n
                  Also includes the UNIQUE CUSTOM AVATAR!\n
                  Start playing early with the alpha version and be part of the Foundation Year 2016. I will create a whole custom character and portrait based on a photo and your desires! Your custom character will appear in a special Class of 2016 Photo, an epic pixel artwork of all Foundation Year classmates. The portrait (and your name) will also appear in the Retropolis Academy of Art Yearbook as one of its most important first students. I will also send you 50 backer updates introducing new features in the alpha version.\n
                  Note: your custom character will be created sometime during the whole Foundation Year, but it will be ready at least before the final class photo is taken. Before then you will create your own character like other players."
    items: kickstarterAlphaItemsWith [
      CatalogKeys.PixelArtAcademy.Kickstarter.NESBlackKeycard
      CatalogKeys.PixelArtAcademy.Kickstarter.ZXCosmopolis
      CatalogKeys.LandsOfIllusions.Character.Avatar.UniqueCustomAvatar
    ]

  # COMPLIMENTARY BUNDLES

  complimentaryDescription = "You must have done something nice as you have been awarded this complimentary game access!"

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Complimentary.BasicGame
    name: "Pixel Art Academy complimentary basic game access"
    description: complimentaryDescription
    items: [
      CatalogKeys.PixelArtAcademy.PlayerAccess
      CatalogKeys.PixelArtAcademy.FreshmanYear
    ]

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Complimentary.FullGame
    name: "Pixel Art Academy complimentary full game access"
    description: complimentaryDescription
    items: [
      CatalogKeys.PixelArtAcademy.PlayerAccess
      CatalogKeys.PixelArtAcademy.FreshmanYear
      CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
      CatalogKeys.Retropolis.DayPass
    ]

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Complimentary.AlphaAccess
    name: "Pixel Art Academy complimentary alpha game access"
    description: complimentaryDescription
    items: complimentaryAlphaItemsWithRetropolisItems 5

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Complimentary.IdeaGarden
    name: "Pixel Art Academy complimentary Idea Garden game access"
    description: complimentaryDescription
    items: complimentaryAlphaItemsWithRetropolisItems 4

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Complimentary.SecretLab
    name: "Pixel Art Academy complimentary Secret Lab game access"
    description: complimentaryDescription
    items: complimentaryAlphaItemsWithRetropolisItems 3

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Complimentary.PatronClub
    name: "Pixel Art Academy complimentary Patron Club game access"
    description: complimentaryDescription
    items: complimentaryAlphaItemsWithRetropolisItems 2

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Complimentary.Investor
    name: "Pixel Art Academy complimentary Investor game access"
    description: complimentaryDescription
    items: complimentaryAlphaItemsWithRetropolisItems 1

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Complimentary.VIP
    name: "Pixel Art Academy complimentary V.I.P. game access"
    description: complimentaryDescription
    items: complimentaryAlphaItemsWithRetropolisItems 0

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Bundles.PixelArtAcademy.Complimentary.Press
    name: "Pixel Art Academy complimentary press pass"
    description: "Thank you for taking the time to play Pixel Art Academy."
    items: complimentaryAlphaItemsWithRetropolisItems 5

kickstarterAlphaItemsWith = (extraItems) ->
  [
    CatalogKeys.PixelArtAcademy.PlayerAccess
    CatalogKeys.PixelArtAcademy.AlphaAccess
    CatalogKeys.PixelArtAcademy.FoundationYear
    CatalogKeys.PixelArtAcademy.FreshmanYear
    CatalogKeys.PixelArtAcademy.SophomoreYear
    CatalogKeys.PixelArtAcademy.JuniorYear
    CatalogKeys.PixelArtAcademy.SeniorYear
    CatalogKeys.PixelArtAcademy.Kickstarter.RetropolisAcademyOfArtYearbook
    CatalogKeys.PixelArtAcademy.Kickstarter.ClassOf2016Artwork
    CatalogKeys.LandsOfIllusions.Character.Creation
    CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarSelection
    CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
  ].concat extraItems

complimentaryAlphaItemsWithRetropolisItems = (keycardColor) ->
  alphaItems = [
    CatalogKeys.PixelArtAcademy.PlayerAccess
    CatalogKeys.PixelArtAcademy.AlphaAccess
    CatalogKeys.PixelArtAcademy.FreshmanYear
    CatalogKeys.LandsOfIllusions.Character.Avatar.AvatarEditor
  ]

  retropolisItems = [
    CatalogKeys.Retropolis.VIP
    CatalogKeys.Retropolis.Investor
    CatalogKeys.Retropolis.PatronClubMember
    CatalogKeys.Retropolis.SecretLabAccess
    CatalogKeys.Retropolis.IdeaGardenAccess
    CatalogKeys.Retropolis.NightlifePass
    CatalogKeys.Retropolis.DayPass
  ]

  alphaItems.concat retropolisItems.slice keycardColor
