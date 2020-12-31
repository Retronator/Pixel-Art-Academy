AE = Artificial.Everywhere
RA = Retronator.Accounts
RS = Retronator.Store

RS.Pages.Admin.Payments.paymentsForSearchFields.publish (searchFields) ->
  check searchFields, Match.ObjectIncluding
    patronId: Match.Optional String
    patronEmail: Match.Optional String

  nonEmptySearchFields = {}

  for property, value of searchFields when value or value is false
    nonEmptySearchFields[property] = value

  throw new AE.ArgumentNullException "At least one search field must be provided." unless _.keys(nonEmptySearchFields).length

  RA.authorizeAdmin()

  RS.Pages.Admin.Payments.paymentsForSearchFields.query nonEmptySearchFields
