app = require '../app'

Q = require 'q'

onCreateEstimate = ->
  currentNimbleContact = null
  currentFBContact = null

  app.nimbleAPI.getDealContact()
  .then (contact) ->
    console.log 'nimble contact is ', contact
    unless contact?.fields?.email?
      return Q.reject 'CONTACT_NOT_FOUND'

    app.exapi.getCompanyData contact.id
    .then (linkedClient) ->
      unless linkedClient
        console.log 'creating new freshBooks user'
        currentNimbleContact = contact
        client =
          first_name: $t: contact.fields['first name']?[0]?.value
          last_name: $t: contact.fields['last name']?[0]?.value
          organization: $t: contact.fields['parent company']?[0]?.value or contact.fields['company name']?[0]?.value
          email: $t: contact.fields['email']?[0]?.value

        app.fbAPI.createClient client
        .then (response) ->

          if response.status = 'ok'
            clientId = response.client_id.$t
            app.exapi.setCompanyData currentNimbleContact.id, { freshBooksClientId: clientId }
            .then ->
              Q.resolve clientId
          else
            Q.reject response
      else
        console.log 'working with existed freshBooks user'
        Q.resolve linkedClient.freshBooksClientId

  .then (fbClientId) ->
    currentFBContact = fbClientId
    estimate =
      client_id: $t: fbClientId
    app.fbAPI.createEstimate estimate

  .then (response) ->

    if response.status = 'ok'
      dealId = app.nimbleAPI.getDealIdFromUrl()
      console.log dealId, response

      estimateId = response.estimate_id.$t
      app.exapi.setCompanyData dealId, {
        freshBooksClientId: currentFBContact
        freshBooksEstimateId: estimateId
      }
    else
      Q.reject response

  .then () ->
    renderOnDealView()

  .catch (error) ->
    app.actions.onNimbleError error

dealViewContainer = null

renderOnDealView = (alertMessage = null) ->
  app.nimbleAPI.getDealContact()
  .then (contact) ->
    if contact
      Q.all [
        app.exapi.getCompanyData contact.id
        app.exapi.getCompanyData app.nimbleAPI.getDealIdFromUrl()
      ]
    else
      Q.resolve [null, null]

  .spread (contactInfo, dealInfo) ->
    fbClientLink = app.fbAPI.getClientLink contactInfo?.freshBooksClientId
    fbEstimateLink = app.fbAPI.getEstimateLink dealInfo?.freshBooksEstimateId

    reactData = { onCreateEstimate, fbClientLink, fbEstimateLink, alertMessage }
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