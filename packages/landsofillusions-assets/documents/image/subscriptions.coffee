LOI = LandsOfIllusions

LOI.Assets.Image.forUrl.publish (url) ->
  check url, String
  
  LOI.Assets.Image.getPublishingDocuments().find {url}
