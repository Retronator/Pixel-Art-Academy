RA = Retronator.Accounts
RS = Retronator.Store

Meteor.publish 'Retronator.Store.Transactions.Payment.forCurrentUser', ->
  # We are doing this inside an autorun in case the user document gets updated and new transactions would get matched.
  @autorun =>
    return unless @userId

    # Select the current user, but we care only about their registered emails
    # or twitter handle since that's how transactions are found.
    user = RA.User.documents.findOne @userId,
      registered_emails: 1
      services:
        twitter:
          screenname: 1

    transactions = RS.Transactions.Transaction.findTransactionsForUser(user).fetch()
    
    # Get all payments from transactions.
    paymentIds = for transaction in transactions
      payment._id for payment in transaction.payments

    paymentIds = _.flatten paymentIds

    RS.Transactions.Payment.documents.find
      _id:
        $in: paymentIds
