AM = Artificial.Mirage
AB = Artificial.Base

class Retronator.Blog
  @id: -> 'Retronator.Blog'
  @getInfo: new AB.Method name: "#{@id()}.getInfo"

  constructor: ->
    Retronator.App.addAdminPage '/admin/blog', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/blog/scripts', @constructor.Pages.Admin.Scripts
