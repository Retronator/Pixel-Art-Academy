AE = Artificial.Everywhere
RA = Retronator.Accounts
RS = Retronator.Store

RS.Pages.Admin.Transactions.transactionsForUserIdOrEmailOrTwitter.publish (userId, email, twitter) ->
  userId = null unless userId?.length
  check userId, Match.OptionalOrNull Match.DocumentId
  check email, Match.OptionalOrNull String
  check twitter, Match.OptionalOrNull String

  throw new AE.ArgumentNullException "User ID or email or Twitter handle must be provided." unless userId or email or twitter

  RA.authorizeAdmin()

  RS.Pages.Admin.Transactions.transactionsForUserIdOrEmailOrTwitter.query userId, email, twitter
