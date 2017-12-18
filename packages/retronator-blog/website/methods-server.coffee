RA = Retronator.Accounts
PADB = PixelArtDatabase

PADB.Website.renderBlogPreview.method (id) ->
  check id, Match.DocumentId
  RA.authorizeAdmin()

  # Relay to server method.
  Retronator.Blog.renderWebsitePreview id
