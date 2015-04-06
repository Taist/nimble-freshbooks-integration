Q = require 'q'

appData = {

}

appErrors =
  CONTACT_NOT_FOUND: 'Please fill \'Person\' field of this deal before creating an estimate'
  FB_PROXY_ERROR: 'Can\'t connect to FreshBooks API. Please switch on integration on FreshBooks'

app =
  api: null
  exapi: {}

  observer: null

  options:
    nimbleToken: null

  init: (api) ->
    app.api = api

    app.exapi.setUserData = Q.nbind api.userData.set, api.userData
    app.exapi.getUserData = Q.nbind api.userData.get, api.userData

    app.exapi.setCompanyData = Q.nbind api.companyData.set, api.companyData
    app.exapi.getCompanyData = Q.nbind api.companyData.get, api.companyData

    require('./freshBooksApi').init app, 'fbAPI'
    require('./nimbleApi').init app, 'nimbleAPI'

  actions:
    onNimbleError: (messageCode) ->
      console.log 'onNimbleError', messageCode
      if appErrors[messageCode]?
        require('./nimble/onDealView') appErrors[messageCode]

    setFreshBooksCreds: (creds) ->
      app.fbAPI.setCreds creds

module.exports = app
