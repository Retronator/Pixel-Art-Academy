AM = Artificial.Mirage
Blog = Retronator.Blog

class Blog.Pages.Admin.Scripts extends AM.Component
  @register 'Retronator.Blog.Pages.Admin.Scripts'

  events: ->
    super.concat
      'click .process-post-history': => Meteor.call 'Retronator.Blog.Pages.Admin.Scripts.processPostHistory'
