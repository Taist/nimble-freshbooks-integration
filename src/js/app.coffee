Q = require 'q'

appData = {

}

app =
  api: null
  exapi: {}

  observer: null

  options:
    nimbleToken: null

  init: (api) ->
    app.api = api

    require('./freshBooksApi').init app, 'fbAPI'
    require('./nimbleApi').init app, 'nimbleAPI'

    app.exapi.setUserData = Q.nbind api.userData.set, api.userData
    app.exapi.getUserData = Q.nbind api.userData.get, api.userData

    app.exapi.setCompanyData = Q.nbind api.companyData.set, api.companyData
    app.exapi.getCompanyData = Q.nbind api.companyData.get, api.companyData

  actions:
    setFreshBooksCreds: (creds) ->
      app.exapi.setUserData 'freshBooksCreds', creds

    getFreshBooksCreds: ->
      app.exapi.getUserData 'freshBooksCreds'

module.exports = app
