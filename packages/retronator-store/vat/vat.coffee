AB = Artificial.Base
AE = Artificial.Everywhere
RS = Retronator.Store

class RS.Vat
  @id: -> 'Retronator.Store.Vat'

  @validateVatId: new AB.Method name: "#{@id()}.validateVatId"

  # Calculate VAT that will match as closely as possible the desired net or total amounts.
  @calculateVat: (options) ->
    throw new AE.ArgumentNullException "You must provide the VAT rate." unless options.vatRate?

    result =
      vatRate: options.vatRate
      
    requireExchangeRate = =>
      throw new AE.ArgumentNullException "You must provide USD to EUR exchange rate if you provide a total amount in USD." unless options.usdToEurExchangeRate
      result.usdToEurExchangeRate = options.usdToEurExchangeRate

    if options.desiredNetAmountEur
      netAmountEur = options.desiredNetAmountEur

    else if options.desiredNetAmountUsd
      requireExchangeRate()

      netAmountEur = options.desiredNetAmountUsd * options.usdToEurExchangeRate
      
    else
      if options.desiredTotalAmountUsd
        requireExchangeRate()
        
        totalAmountEur = options.desiredTotalAmountUsd * options.usdToEurExchangeRate

      else
        throw new AE.ArgumentNullException "You must provide either total or net EUR amount." unless options.desiredTotalAmountEur

        totalAmountEur = options.desiredTotalAmountEur

      netRatio = 1 / (1 + options.vatRate)
      netAmountEur = totalAmountEur * netRatio

    # We do the VAT calculation based on two digits of precision.
    result.netAmountEur = Math.round(netAmountEur * 100) / 100

    vatAmountEur = result.netAmountEur * options.vatRate
    result.vatAmountEur = Math.round(vatAmountEur * 100) / 100

    result
