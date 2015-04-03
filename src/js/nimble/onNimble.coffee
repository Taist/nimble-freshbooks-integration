app = require '../app'

onCreateEstimate = ->
  app.nimbleAPI.getDealContact()

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
