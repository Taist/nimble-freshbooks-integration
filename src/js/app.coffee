Q = require 'q'

XMLMapping = require 'xml-mapping'

appData = {

}

sendFBRequest = (requestData) ->
  app.actions.getFreshBooksCreds()
  .then (creds) ->
    Q.when $.ajax
      url: creds.url
      headers:
        Authorization: 'Basic ' + btoa "#{creds.token}:"
      method: 'POST'
      data: XMLMapping.dump requestData, throwErrors: true, header: true
      dataType: 'text'
  .then (result) ->
    Q.resolve XMLMapping.load result, throwErrors: true
  .catch (err) ->
    console.log err

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
      app.exapi.setUserData 'freshBooksCreds', creds

    getFreshBooksCreds: ->
      app.exapi.getUserData 'freshBooksCreds'

  fbapi:
    getClients: ->
      sendFBRequest
        request:
          method: 'client.list'
      .then (clients) ->
        console.log clients

    createClient: (client) ->
      sendFBRequest
        request:
          method: 'client.create'
          client:
            first_name: $t: 'Jane'
            last_name: $t: 'Doe'
            email: $t: 'janedoe@freshbooks.com'
      .then (result) ->
        console.log result

module.exports = app
