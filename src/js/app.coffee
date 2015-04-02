Q = require 'q'

appData = {

}

app =
  api: null
  exapi: {}

  init: (api) ->
    app.api = api

    app.exapi.setUserData = Q.nbind api.userData.set, api.userData
    app.exapi.getUserData = Q.nbind api.userData.get, api.userData

    app.exapi.setCompanyData = Q.nbind api.companyData.set, api.companyData
    app.exapi.getCompanyData = Q.nbind api.companyData.get, api.companyData

  actions:
    setFreshBooksCreds: (creds) ->
      app.exapi.setCompanyData 'freshBooksCreds', creds

    getFreshBooksCreds: ->
      app.exapi.getCompanyData 'freshBooksCreds'

module.exports = app
