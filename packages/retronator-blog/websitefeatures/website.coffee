AM = Artificial.Mummification
PADB = PixelArtDatabase

class PADB.Website extends PADB.Website
  # retronatorDailyFeature:
  #   enabled: boolean if this website is featured in Retronator Daily
  #   order: number where along the features the website should appear, lower is sooner
  #   preview: preview of the website frontpage
  #     imageUrl: link to the rendered frontpage on our assets server
  @Meta
    name: @id()
    replaceParent: true

  # Methods

  @renderRetronatorDailyFeaturePreview: @method 'renderRetronatorDailyFeaturePreview'
