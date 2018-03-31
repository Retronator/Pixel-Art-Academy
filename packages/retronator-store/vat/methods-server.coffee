AB = Artificial.Babel
AE = Artificial.Everywhere
RS = Retronator.Store

validateVat = Meteor.wrapAsync require 'validate-vat'

RS.Vat.validateVatId.method (vatId) ->
  check vatId, String

  # Break down the string into the country and number part. The API requires uppercase country code.
  country = vatId[0..1].toUpperCase()
  number = vatId[2..]

  try
    result = validateVat country, number

  catch error
    throw new AE.ArgumentException "#{error.message}."

  throw new AE.ArgumentException "Vat ID is not valid." unless result.valid

  result
