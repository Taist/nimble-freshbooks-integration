app = require '../app'

Q = require 'q'

onCreateEstimate = ->
  currentContact = null

  app.nimbleAPI.getDealContact()
  .then (contact) ->
    console.log 'nimble contact is ', contact
    unless contact?.fields?.email?
      return Q.reject 'CONTACT_NOT_FOUND'

    currentContact = contact
    client =
      first_name: $t: contact.fields['first name']?[0]?.value
      last_name: $t: contact.fields['last name']?[0]?.value
      organization: $t: contact.fields['parent company']?[0]?.value or contact.fields['company name']?[0]?.value
      email: $t: contact.fields['email']?[0]?.value

    app.fbAPI.createClient client
  .then (response) ->
    if response.status = 'ok'
      Q.all [
        app.exapi.setCompanyData app.nimbleAPI.getDealIdFromUrl(), { freshBooksClient: response.client_id.$t }
        app.exapi.setCompanyData currentContact.id, { freshBooksClient: response.client_id.$t }
      ]
    else
      Q.reject response
  .then () ->
    renderOnDealView()
  .catch (error) ->
    app.actions.onNimbleError error

dealViewContainer = null

renderOnDealView = (alertMessage = null) ->
  # app.exapi.getCompanyData app.nimbleAPI.getDealIdFromUrl()
  # .then (dealInfo) ->
  app.nimbleAPI.getDealContact()
  .then (contact) ->
    if contact
      app.exapi.getCompanyData contact.id
    else
      Q.resolve null
  .then (dealInfo) ->
    app.fbAPI.getClientLink dealInfo?.freshBooksClient
  .then (fbClientLink) ->

    reactData = { onCreateEstimate, fbClientLink, alertMessage }
    console.log 'renderOnDealView', reactData

    React = require 'react'
    reactPage = require '../react/nimble/dealView'
    React.render reactPage( reactData ), dealViewContainer
  .catch (error) ->
    console.log error
    app.actions.onNimbleError error

module.exports = (alertMessage) ->
  unless dealViewContainer
    app.observer.waitElement '.DealView .profileInfoWrapper td.generalInfo', (elem) ->
      dealViewContainer = document.createElement 'div'
      elem.appendChild dealViewContainer
      renderOnDealView alertMessage
  else
    renderOnDealView alertMessage
