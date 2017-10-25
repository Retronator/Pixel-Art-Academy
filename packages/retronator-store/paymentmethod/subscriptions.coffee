RA = Retronator.Accounts
RS = Retronator.Store

RS.PaymentMethod.forCurrentUser.publish ->
  # We are doing this inside an autorun in case the user document gets updated and new payment methods would get matched.
  @autorun =>
    return unless @userId

    # Select the current user, but we care only about their registered emails
    # or twitter handle since that's how transactions are found.
    user = RA.User.documents.findOne @userId,
      registered_emails: 1
      services:
        twitter:
          screenname: 1
          
    RS.PaymentMethod.findPaymentMethodsForUser user
