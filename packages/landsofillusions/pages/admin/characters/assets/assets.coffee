AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Pages.Admin.Characters.Assets extends AM.Component
  @register 'LandsOfIllusions.Pages.Admin.Characters.Assets'

  onCreated: ->
    super arguments...

    @avatarUrls = new ReactiveField null

  events: ->
    super(arguments...).concat
      'click .actor-assets-download-button': @onClickActorAssetsDownloadButton
      'click .render-avatar-button': @onClickRenderAvatarButton
      'click .creature-assets-download-button': @onClickCreatureAssetsDownloadButton

  onClickActorAssetsDownloadButton: (event) ->
    password = @$('.password').val()

    # Encrypt userId with the password.
    userId = CryptoJS.AES.encrypt(Meteor.userId(), password).toString()

    $link = $('<a style="display: none">')
    $('body').append $link

    link = $link[0]
    link.download = 'actorassets.zip'
    link.href = "/admin/landsofillusions/characters/assets/actorassets.zip?userId=#{encodeURIComponent userId}"
    link.click()

    $link.remove()

  onClickRenderAvatarButton: (event) ->
    characterId = @$('.character-id').val()
    characterUrl = @$('.character-url').val()
    password = @$('.password').val()

    # Encrypt character parameter with the password.
    parameter = if characterId then 'id' else 'url'
    value = CryptoJS.AES.encrypt(characterId or characterUrl, password).toString()

    url = "/admin/landsofillusions/characters/assets/avatartexture.png?#{parameter}=#{encodeURIComponent value}"
    
    @avatarUrls
      paletteData: "#{url}&texture=paletteData"
      normal: "#{url}&texture=normal"

  onClickCreatureAssetsDownloadButton: (event) ->
    password = @$('.password').val()

    # Encrypt userId with the password.
    userId = CryptoJS.AES.encrypt(Meteor.userId(), password).toString()

    $link = $('<a style="display: none">')
    $('body').append $link

    link = $link[0]
    link.download = 'creatureassets.zip'
    link.href = "/admin/landsofillusions/characters/assets/creatureassets.zip?userId=#{encodeURIComponent userId}"
    link.click()

    $link.remove()
