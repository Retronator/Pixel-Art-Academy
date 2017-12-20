AE = Artificial.Everywhere
RA = Retronator.Accounts
Blog = Retronator.Blog

Meteor.methods
  'Retronator.Blog.Pages.Admin.Scripts.processPostHistory': ->
    RA.authorizeAdmin()

    console.log "Fetching and reprocessing all Retronator blog posts …"

    # Fetch all posts and force reprocessing.
    Blog.processPostHistory reprocess: true
