AM = Artificial.Mummification
PADB = PixelArtDatabase

class PADB.Website extends PADB.Website
  # blogFeature:
  #   enabled: boolean if this website is featured in Retronator Daily
  #   order: number where along the features the website should appear, lower is sooner
  #   preview: preview of the website frontpage
  #     imageUrl: link to the rendered frontpage on our assets server
  #     customCss: extra css to be used when rendering the preview
  @Meta
    name: @id()
    replaceParent: true

  # Methods

  @renderBlogPreview: @method 'renderBlogPreview'
