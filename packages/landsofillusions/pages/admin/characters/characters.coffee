AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Pages.Admin.Characters extends AM.Component
  @register 'LandsOfIllusions.Pages.Admin.Characters'

  onCreated: ->
    super arguments...

    @avatarUrls = new ReactiveField null

  events: ->
    super(arguments...).concat
      'click .render-avatar-button': @onClickRenderAvatarButton

  onClickRenderAvatarButton: (event) ->
    characterId = @$('.character-id').val()
    characterUrl = @$('.character-url').val()
    password = @$('.password').val()

    # Encrypt character parameter with the password.
    parameter = if characterId then 'id' else 'url'
    value = CryptoJS.AES.encrypt(characterId or characterUrl, password).toString()

    url = "/admin/landsofillusions/characters/avatartexture.png?#{parameter}=#{encodeURIComponent value}"
    
    @avatarUrls
      paletteData: "#{url}&texture=paletteData"
      normal: "#{url}&texture=normal"
