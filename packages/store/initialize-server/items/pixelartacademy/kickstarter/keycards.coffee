RA = Retronator.Accounts
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

Meteor.startup ->
  # KICKSTARTER KEYCARDS
  
  RS.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.WhiteKeycard
    name: "White keycard"
    description: "Kickstarter-exclusive keycard skin for your ID card."
    items: listOfRetroplisItemsForKeycardColor 7

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.YellowKeycard
    name: "Yellow keycard"
    description: "Kickstarter-exclusive keycard that comes pre-loaded with the day pass."
    items: listOfRetroplisItemsForKeycardColor 6

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.CyanKeycard
    name: "Cyan keycard"
    description: "Kickstarter-exclusive keycard that comes pre-loaded with the day and nightlife passes."
    items: listOfRetroplisItemsForKeycardColor 5

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.GreenKeycard
    name: "Green keycard"
    description: "Kickstarter-exclusive keycard that comes pre-loaded with Retropolis passes and gives you access to the idea garden."
    items: listOfRetroplisItemsForKeycardColor 4

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.MagentaKeycard
    name: "Magenta keycard"
    description: "Kickstarter-exclusive keycard that comes pre-loaded with Retropolis passes and gives you access to the idea garden and secret lab."
    items: listOfRetroplisItemsForKeycardColor 3

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.RedKeycard
    name: "Red keycard"
    description: "Kickstarter-exclusive keycard that comes pre-loaded with Retropolis passes, Retronator HQ access, and gives you membership to the Patron Club."
    items: listOfRetroplisItemsForKeycardColor 2

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.BlueKeycard
    name: "Blue keycard"
    description: "Kickstarter-exclusive keycard that comes pre-loaded with Retropolis passes, Retronator HQ access, membership to the Patron Club, and designates you as one of Retropolis' investors."
    items: listOfRetroplisItemsForKeycardColor 1

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.BlackKeycard
    name: "Black keycard"
    description: "Kickstarter-exclusive keycard that comes pre-loaded with Retropolis passes, Retronator HQ access, membership to the Patron Club, and designates you as one of Retropolis' investor VIPs."
    items: listOfRetroplisItemsForKeycardColor 0

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.ZXBlackKeycard
    name: "ZX black keycard"
    description: "Kickstarter-exclusive ZX Spectrum-styled keycard that comes pre-loaded with Retropolis passes, Retronator HQ access, membership to the Patron Club, and designates you as one of Retropolis' investor VIPs."
    items: listOfRetroplisItemsForKeycardColor 0

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.Kickstarter.NESBlackKeycard
    name: "NES black keycard"
    description: "Kickstarter-exclusive NES-styled keycard that comes pre-loaded with Retropolis passes, Retronator HQ access, membership to the Patron Club, and designates you as one of Retropolis' investor VIPs."
    items: listOfRetroplisItemsForKeycardColor 0

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.PixelArtAcademy.RetronatorBlackKeycard
    name: "Retronator black keycard"
    description: "RETRONATOR: Top-level administrator access to the whole system."
    items: listOfRetroplisItemsForKeycardColor 0

  RS.Transactions.Item.create
    catalogKey: CatalogKeys.Retropolis.PressPass
    name: "Press Pass"
    description: "Press keycard that also gives you Retropolis day and nightlife passes."
    items: listOfRetroplisItemsForKeycardColor 5

listOfRetroplisItemsForKeycardColor = (keycardColor) ->
  items = [
    CatalogKeys.Retropolis.VIP
    CatalogKeys.Retropolis.Investor
    CatalogKeys.Retropolis.PatronClubMember
    CatalogKeys.Retropolis.SecretLabAccess
    CatalogKeys.Retropolis.IdeaGardenAccess
    CatalogKeys.Retropolis.NightlifePass
    CatalogKeys.Retropolis.DayPass
  ]

  items.slice keycardColor
  