RA = Retronator.Accounts
RS = Retronator.Store

CatalogKeys = RS.Items.CatalogKeys

Document.startup ->
  return if Meteor.settings.startEmpty

  # RETRONATOR ITEMS

  RS.Item.create
    catalogKey: CatalogKeys.Retronator.Admin
    name: "Retronator Administrator"
    description: "You are the boss."

  RS.Item.create
    catalogKey: CatalogKeys.Retronator.Patreon.Subscriptions
    name: "Pixel Art Academy - Subscription"
    description: """If you'd prefer to pay for the game on a monthly basis, you can become a patron of Matej 'Retro' Jan
                    on Patreon. The pledge tiers are offered at 80% discount of the prices, and all your payments are
                    added to your Retronator Store account so you can buy one of the game packages after you've
                    contributed enough. Patreon subscription does not however give you a Steam key for Pixel Art
                    Academy: Learn Mode."""
    storeUrl: 'https://www.patreon.com/retro'
    storeSeller: 'Patreon'

  RS.Item.create
    catalogKey: CatalogKeys.Retronator.Patreon.PatreonKeycard
    name: "Patreon keycard"
    description: "As a current patron you have a Patreon keycard skin for your ID card."

  RS.Item.create
    catalogKey: CatalogKeys.Retronator.Patreon.EarlyBirdKeycard
    name: "Commemorative Patreon keycard"
    description: "Commemorative Patreon early-bird keycard skin for your ID card. It's the only way to say \"I was the first to support Retronator on Patreon\"."
    items: [
      CatalogKeys.Retropolis.PatronClubMember
      CatalogKeys.Retropolis.SecretLabAccess
      CatalogKeys.Retropolis.IdeaGardenAccess
      CatalogKeys.Retropolis.NightlifePass
      CatalogKeys.Retropolis.DayPass
    ]
