app = require '../app'

Q = require 'q'

onCreateEstimate = ->
  currentNimbleContact = null
  currentFBContact = null

  app.nimbleAPI.getDealContact()
  .then (contact) ->
    console.log 'nimble contact is ', contact
    unless contact?.fields?.email? and contact?.record_type is 'person'
      return Q.reject 'CONTACT_NOT_FOUND'

    app.exapi.getCompanyData contact.id
    .then (linkedClient) ->
      unless linkedClient
        console.log 'creating new freshBooks user'
        currentNimbleContact = contact
        client =
          first_name: $t: contact.fields['first name']?[0]?.value
          last_name: $t: contact.fields['last name']?[0]?.value
          organization: $t: contact.fields['parent company']?[0]?.value
          email: $t: contact.fields['email']?[0]?.value

        app.fbAPI.createClient client
        .then (response) ->

          if response.status is 'ok'
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

    if response.status is 'ok'
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
dealViewEstimateTable = null

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

    app.fbAPI.getEstimate dealInfo?.freshBooksEstimateId
    .then (response) ->
      console.log response.estimate

      fbClientLink = app.fbAPI.getClientLink contactInfo?.freshBooksClientId
      fbEstimateLink = app.fbAPI.getEstimateLink dealInfo?.freshBooksEstimateId

      reactData = { onCreateEstimate, fbClientLink, fbEstimateLink, alertMessage }
      console.log 'renderOnDealView', reactData

      React = require 'react'
      reactPage = require '../react/nimble/dealView'
      React.render reactPage( reactData ), dealViewContainer

      estimateTableData = {
        amount: response.estimate?.amount.$t
        currency: response.estimate?.currency_code.$t
        time: (response.estimate?.lines?.line or []).filter (line) ->
          line?.name?.$t? and line?.type?.$t is 'Time'
        item: (response.estimate?.lines?.line or []).filter (line) ->
          line?.name?.$t? and line?.type?.$t isnt 'Time'
      }
      reactComponent = require '../react/nimble/dealViewEstimateTable'
      React.render reactComponent( estimateTableData ), dealViewEstimateTable

  .catch (error) ->
    console.log error
    app.actions.onNimbleError error

module.exports = (alertMessage) ->
  unless dealViewContainer
    app.observer.waitElement '.DealView .profileInfoWrapper', (elem) ->

      dealViewContainer = document.createElement 'div'
      elem.querySelector('td.generalInfo').appendChild dealViewContainer

      dealViewEstimateTable = document.createElement 'div'
      elem.insertBefore dealViewEstimateTable, elem.querySelector('.fullInfoContainer')

      renderOnDealView alertMessage
  else
    renderOnDealView alertMessage
