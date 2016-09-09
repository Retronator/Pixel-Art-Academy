RA = Retronator.Accounts
RS = Retronator.Store

Meteor.startup ->
  # RETROPOLIS ITEMS

  RA.Transactions.Item.create
    catalogKey: RS.Items.CatalogKeys.Retropolis.DayPass
    name: "Retropolis Day Pass"
    description: "Access to non-essential day-time locations like video game arcades."

  RA.Transactions.Item.create
    catalogKey: RS.Items.CatalogKeys.Retropolis.NightlifePass
    name: "Retropolis Nightlife Pass"
    description: "Access to bars and clubs for chilling out, off-topic chatter and meeting new people."

  RA.Transactions.Item.create
    catalogKey: RS.Items.CatalogKeys.Retropolis.IdeaGardenAccess
    name: "Retronator HQ Idea Garden"
    description: "Visit Retronator HQ wit its Idea Garden where you can explore designs of new features."

  RA.Transactions.Item.create
    catalogKey: RS.Items.CatalogKeys.Retropolis.SecretLabAccess
    name: "Retronator HQ Secret Lab"
    description: "Visit the laboratories in Retronator HQ and be the first to test early prototypes and experimental features."

  RA.Transactions.Item.create
    catalogKey: RS.Items.CatalogKeys.Retropolis.PatronClubMember
    name: "Patron Club Membership"
    description: "Hang out with Retro and other patrons at exclusive patron lounges around the city."

  RA.Transactions.Item.create
    catalogKey: RS.Items.CatalogKeys.Retropolis.Investor
    name: "Investor"
    description: "Your contributions give support to features in Retronator Idea Garden, influencing which ones get picked for development next."

  RA.Transactions.Item.create
    catalogKey: RS.Items.CatalogKeys.Retropolis.VIP
    name: "V.I.P."
    description: "You are one of the most important people in Retropolis, gaining special abilities in the world."
