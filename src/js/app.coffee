Q = require 'q'

appData = {

}

appErrors =
  COMPANY_NOT_FOUND: "Please link a company to the deal"
  COMPANY_NO_PEOPLE: "Please link a person to the company linked to the deal"
  COMPANY_ADDRESS_IS_INCOMPLETE: "Company address is incopmlete. Please fill in Street address and City"
  COMPANY_NO_PEOPLE_NO_ADDRESS: "Please link a person to a company and fill in company's address: Street address and City"
  NO_MEMBERS_WITH_EMAIL: "Please set email for the person linked to the company in the deal"
  FB_PROXY_ERROR: "Can't connect to Freshbooks. Please enable its integration with Nimble (My account -> Freshbooks API)"
  BIDSKETCH_PROXY_ERROR: "Can't connect to Bidsketch. Please enable its integration with Nimble"

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
    require('./bidsketchApi').init app, 'bidsketchAPI'

  getError: (messageCode) ->
    appErrors[messageCode]

  actions:
    onNimbleError: (messageCode) ->
      console.log 'onNimbleError'
      require('./nimble/onDealView') {
        alertMessage: app.getError messageCode
        isSpinnerActive: false
      }

    onCreateProposal: (deal) ->
      require('./bidsketch/onCreateProposal') deal

    onCreateEstimate: () ->
      require('./freshbooks/onCreateEstimate')()
      .then () ->
        require('./nimble/onDealView') isSpinnerActive: false
      .catch (error) ->
        app.actions.onNimbleError error

    setFreshBooksCreds: (creds) ->
      app.fbAPI.setCreds creds

    setBidsketchCreds: (creds) ->
      app.bidsketchAPI.setCreds creds

module.exports = app
