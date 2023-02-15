AE = Artificial.Everywhere
AT = Artificial.Telepathy

# MaxMind IP analysis service.
class AT.MaxMind
  @countryForIp: (ip) ->
    @countryDataForIp(ip).country.iso_code.toLowerCase()

  @countryDataForIp: (ip) ->
    throw new AE.InvalidOperationException 'MaxMind account was not configured.' unless Meteor.settings.maxMind

    username = Meteor.settings.maxMind.accountId
    password = Meteor.settings.maxMind.licenseKey

    url = "https://@geoip.maxmind.com/geoip/v2.1/country/#{ip}"

    response = HTTP.get url, auth: "#{username}:#{password}"
    JSON.parse response.content
