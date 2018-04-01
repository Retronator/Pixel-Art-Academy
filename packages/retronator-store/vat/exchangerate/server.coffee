RS = Retronator.Store

class RS.Vat.ExchangeRate extends RS.Vat.ExchangeRate
  @_usdToEur = null
  @_eurToUsd = null

  @updateExchangeRates: (callback) ->
    # Request USD reference rates.
    url = 'https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/usd.xml'

    # Allow to cache the result up to a day.
    options =
      headers:
        'Cache-Control': 'max-age=86400'

    HTTP.get url, options, (error, result) =>
      if error
        console.error "Could not retrieve USD exchange rate XML file.", error
        return

      xml = xml2js.parseStringSync result.content

      # Find the last exchange rate.
      latestTime = 0
      latestEurToUsdRate = null

      for obs in xml.CompactData.DataSet[0].Series[0].Obs
        time = Date.parse obs.$.TIME_PERIOD

        if time > latestTime
          latestTime = time
          latestEurToUsdRate = parseFloat obs.$.OBS_VALUE

      if latestEurToUsdRate
        @eurToUsd = latestEurToUsdRate

        # Exchange rates are defined to 4 decimals.
        @usdToEur = Math.round(10000 / latestEurToUsdRate) / 10000

      else
        console.error "Failed to parse USD exchange rate XML file."

      callback?()

Meteor.startup ->
  # Update exchange rates on startup.
  RS.Vat.ExchangeRate.updateExchangeRates()

  # Update exchange rates every day.
  new Cron =>
    RS.Vat.ExchangeRate.updateExchangeRates ->
      console.log "Latest exchange rates are"
      console.log "EUR to USD:", RS.Vat.ExchangeRate.eurToUsd
      console.log "USD to EUR:", RS.Vat.ExchangeRate.usdToEur
  ,
    hour: 3
    minute: 0
