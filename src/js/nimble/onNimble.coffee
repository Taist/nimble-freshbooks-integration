app = require '../app'

onCreateEstimate = ->
  app.nimbleAPI.getDealContact()
  .then (contact) ->
    console.log contact

    client =
      first_name: $t: contact.fields['first name']?[0]?.value
      last_name: $t: contact.fields['last name']?[0]?.value
      organization: $t: contact.fields['parent company']?[0]?.value
      email: $t: contact.fields['email']?[0]?.value

    app.fbAPI.createClient client
  .then (response) ->
    if response.status = 'ok'
      app.exapi.setCompanyData app.nimbleAPI.getDealIdFromUrl(), { freshBooksClient: response.client_id.$t }
  .catch (error) ->
    console.log error

onDealView = ->
  app.observer.waitElement '.DealView .profileInfoWrapper td.generalInfo', (elem) ->
    container = document.createElement 'div'
    elem.appendChild container

    React = require 'react'
    reactPage = require '../react/nimble/dealView'
    React.render reactPage( { onCreateEstimate } ), container

routesByHashes =
  '^app/deals/view': onDealView

setRoutes = ->
  for hashRegexp, routeProcessor of routesByHashes
    do (hashRegexp, routeProcessor) =>
      app.api.hash.when hashRegexp, routeProcessor

proxy = require '../helpers/xmlHttpProxy'

extractNimbleAuthTokenFromRequest = ->
  proxy.onRequestFinish (request) ->
    url = request.responseURL
    tokenMatches = url.match /\/api\/sessions\/([0-9abcdef-]{36})\?/
    if tokenMatches?
      app.options.nimbleToken = tokenMatches[1]

module.exports = ->
  setRoutes()
  extractNimbleAuthTokenFromRequest()
