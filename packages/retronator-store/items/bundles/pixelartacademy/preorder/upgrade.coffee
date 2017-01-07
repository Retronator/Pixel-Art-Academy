AE = Artificial.Everywhere
RA = Retronator.Accounts
RS = Retronator.Store
CatalogKeys = RS.Items.CatalogKeys

class RS.Items.Bundles.PixelArtAcademyPreorderUpgrade extends RS.Transactions.Item
  validateEligibility: ->
    # Only existing players can buy upgrades.
    user = Meteor.user()
    @_throwEligibilityException "You need to be logged in to purchase an upgrade." unless user

    # Make sure the user has one of the prerequisite items.
    transactions = RS.Transactions.Transaction.findTransactionsForUser(user).fetch()

    for transaction in transactions
      for transactionItem in transaction.items
        prerequisiteFound = true if transactionItem.item.catalogKey in @constructor.eligiblePrerequisiteItems

    @_throwEligibilityException "You need to have one of the required basic game packages for this upgrade to make sense." unless prerequisiteFound 

    # Make sure the user didn't already buy this upgrade.
    for transaction in transactions
      for transactionItem in transaction.items
        @_throwEligibilityException "You already have this upgrade." if transactionItem.item.catalogKey is @constructor.catalogKey

    # All good, it looks like this user has one of the prerequisite items and hasn't bought this upgrade yet.
