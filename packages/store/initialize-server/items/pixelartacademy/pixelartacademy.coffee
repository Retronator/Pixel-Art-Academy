RA = Retronator.Accounts
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

Meteor.startup ->
  # PIXEL ART ACADEMY YEARS

  RA.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.FoundationYear
    name: "Pixel Art Academy - Foundation Year"
    description: "You are part of the founding class of 2016 with access to the prototype alpha version of Pixel Art Academy."

  RA.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.FreshmanYear
    name: "Pixel Art Academy - Freshman Year"
    description: "The first year of gameplay that will be released throughout 2017."

  RA.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.SophomoreYear
    name: "Pixel Art Academy - Sophomore Year"
    description: "The second year of gameplay if we can keep development sustainable until 2018."

  RA.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.JuniorYear
    name: "Pixel Art Academy - Junior Year"
    description: "The third year of gameplay if we're still alive and kicking for 2019."

  RA.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.SeniorYear
    name: "Pixel Art Academy - Senior Year"
    description: "The final year of gameplay if we're lucky enough to reach the end of the decade in 2020."
    
  # CLASS HELP

  RA.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Help.ClassHelp
    name: "Pixel Art Academy - Class Help"
    description: "Request help on an assignment or general art guidance. Retro will write you detailed feedback on your artwork and steps to take in the future."

  RA.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Help.Paintover
    name: "Pixel Art Academy - Class Help"
    description: "Request a paintover of one of your artwork. Retro will accompany it with detailed feedback and general art guidance."

  RA.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Help.PaintoverVideo
    name: "Pixel Art Academy - Class Help"
    description: "Request a paintover of one of your artwork and Retro will create a video detailing his changes and the art lessons contained within. He will also write you general art guidance for meeting your own goals."

  # KICKSTARTER

  RA.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.RetropolisAcademyOfArtYearbook
    name: "Retropolis Academy of Art Kickstarter Yearbook"
    description: "As a Kickstarter backer, your will be listed in the special edition of the Retropolis Academy of Art Yearbook."

  RA.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.ClassOf2016Artwork
    name: "Backers-only Artwork: Founding Class of 2016"
    description: "You will appear in a Kickstarter-exclusive Class of 2016 Photo, an epic pixel artwork of the main campus quad with all Kickstarter Foundation Year classmates."

  RA.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.ZXCosmopolis
    name: "Artwork: ZX Cosmopolis"
    description: "Huge signed canvas print of ZX Cosmopolis, in real life and as a unique game item."

  RA.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.PixelChinaMountains
    name: "Artwork: Pixel China Mountains"
    description: "Huge signed canvas print of Pixel China Mountains, in real life and as a unique game item."

