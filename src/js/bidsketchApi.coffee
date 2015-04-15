app = null

bidsketchAPI =
  setCreds: (creds) ->
    app.exapi.setCompanyData 'bidsketchCreds', creds

  getCreds: ->
    app.exapi.getCompanyData 'bidsketchCreds'

module.exports =
  init: (_app, propertyName) ->
    app = _app
    _app[propertyName] = bidsketchAPI
