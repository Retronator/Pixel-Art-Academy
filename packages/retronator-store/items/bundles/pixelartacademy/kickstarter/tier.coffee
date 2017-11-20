AE = Artificial.Everywhere
RA = Retronator.Accounts
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

# These are tiers that you can purchase in the store if you were a backer that hasn't selected a reward.
class RS.Items.Bundles.PixelArtAcademyKickstarterTier extends RS.Item
  validateEligibility: ->
    user = Retronator.user()
    @_throwEligibilityException "You need to be logged in to select a Kickstarter tier." unless user

    # Find this user's kickstarter pledge.
    transactions = RS.Transaction.getValidTransactionsForUser user

    for transaction in transactions
      for payment in transaction.payments
        if payment.type is RS.Payment.Types.KickstarterPledge
          # Make sure the pledge is for Pixel Art Academy.
          payment.refresh()

          if payment.project is RS.Payment.Projects.PixelArtAcademy
            pledge = payment
            break

      break if pledge

    @_throwEligibilityException "You need to have a Kickstarter pledge to select a Kickstarter tier." unless pledge

    @_throwEligibilityException "You must have pledged more than this tier to select it." if pledge.amount < @constructor.price

    # Make sure the user hasn't already selected a Kickstarter tier.
    kickstarterTiers = for tierName, tier of RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter
      if _.isObject tier
        for subTierName, subTier of tier
          subTier

      else
        tier

    kickstarterTiers = _.flatten kickstarterTiers

    # Remove the no reward tier, since that one doesn't make you ineligible.
    kickstarterTiers = _.without kickstarterTiers, RS.Items.CatalogKeys.Bundles.PixelArtAcademy.Kickstarter.NoReward

    for transaction in transactions
      for transactionItem in transaction.items
        @_throwEligibilityException "You have already selected a Kickstarter tier." if transactionItem.item.catalogKey in kickstarterTiers

    # All good, it looks like this is a backer who hasn't selected a tier yet and has pledge at least as much as needed.
