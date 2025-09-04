RA = Retronator.Accounts
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

Document.startup ->
  return if Meteor.settings.startEmpty

  # PIXEL ART ACADEMY ACCESS

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.PlayerAccess
    name: "Pixel Art Academy - Player access"
    description: "You are a player of Pixel Art Academy! Enter the game world and play through chapters once they're released."

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.AlphaAccess
    name: "Pixel Art Academy - Alpha access"
    description: "You can test chapters while they're still in development."

  # PIXEL ART ACADEMY YEARS

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.FoundationYear
    name: "Pixel Art Academy - Foundation Year"
    description: "You were part of the founding class of 2016 and played the early prototype before it was even cool."

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.FreshmanYear
    name: "Pixel Art Academy - Freshman Year"
    description: "Volume one of Pixel Art Academy! You have access to game chapters that will constitute the first year at the Academy."

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.SophomoreYear
    name: "Pixel Art Academy - Sophomore Year"
    description: "Access to second volume chapters that continue your story at the Academy."

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.JuniorYear
    name: "Pixel Art Academy - Junior Year"
    description: "Third volume chapters, consisting of your third year at the academy."

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.SeniorYear
    name: "Pixel Art Academy - Senior Year"
    description: "Final volume of Pixel Art Academy chapters, concluding the story arc of the game."
    
  # CLASS HELP

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Help.ClassHelp
    name: "Pixel Art Academy - Class help"
    description: "Request help on an assignment or general art guidance. Retro will write you detailed feedback on your artwork and steps to take in the future."

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Help.Paintover
    name: "Pixel Art Academy - Class help"
    description: "Request a paintover of one of your artwork. Retro will accompany it with detailed feedback and general art guidance."

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Help.PaintoverVideo
    name: "Pixel Art Academy - Class help"
    description: "Request a paintover of one of your artwork and Retro will create a video detailing his changes and the art lessons contained within. He will also write you general art guidance for meeting your own goals."

  # KICKSTARTER

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.RetropolisAcademyOfArtYearbook
    name: "Retropolis Academy of Art Kickstarter Yearbook"
    description: "As a Kickstarter backer, you will be listed in the special edition of the Retropolis Academy of Art Yearbook."

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.ClassOf2016Artwork
    name: "Backers-only Artwork: Founding Class of 2016"
    description: "You will appear in a Kickstarter-exclusive Class of 2016 Photo, an epic pixel artwork of the main campus quad with all Kickstarter Foundation Year classmates."

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.ZXCosmopolis
    name: "Artwork: ZX Cosmopolis"
    description: "Huge signed canvas print of ZX Cosmopolis, in real life and as a unique game item."

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.PixelChinaMountains
    name: "Artwork: Pixel China Mountains"
    description: "Huge signed canvas print of Pixel China Mountains, in real life and as a unique game item."

  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.ArtworkShipping
    name: "Artwork Shipping"
    description: "Shipping cost for sending the physical artwork in the US."
  
  # STEAM
  
  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Steam.LearnMode.DefaultReleaseKey
    name: "Pixel Art Academy: Learn Mode - Steam key"
    description: "Get the downloadable version of Learn Mode on Steam."
    isKey: true
  
  # Note: Both items now have the same description since Learn Mode is
  # released and there is no difference between the keys anymore.
  RS.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Steam.LearnMode.ReleaseStateOverrideKey
    name: "Pixel Art Academy: Learn Mode - Steam key"
    description: "Get the downloadable version of Learn Mode on Steam."
    isKey: true
