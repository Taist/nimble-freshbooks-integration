app = require '../app'

Q = require 'q'

prepareFee = (fee, type) ->
  name: fee.name.$t
  description: fee.description.$t ? fee.name.$t
  feetype: type
  amount: fee.unit_cost.$t
  quantity: fee.quantity.$t
  unit: 'Product' if type is 'custom'

onCreateProposal = (deal) ->
  if deal.fees.item.length is 0 and deal.fees.time.length is 0
    return Q.reject 'ESTIMATE_IS_EMPTY'

  app.nimbleAPI.getDealInfo()

  .then (dealInfo) ->
    require('../nimble/prepareCompanyInfo') dealInfo

  .then (companyInfo) ->
    { companyAddress, companyMembers, contact } = companyInfo

    app.exapi.getCompanyData deal.info.contactPersonId
    .then (linkedClient) ->
      unless linkedClient?.bidsketchClientId?

        firstPerson = null

        companyMembers = companyMembers.filter (member) ->
          if member.id isnt deal.info.contactPersonId
            true
          else
            firstPerson = member
            false

        client =
          first_name: firstPerson.first_name
          last_name: firstPerson.last_name
          email: firstPerson.email
          name: contact.fields['company name']?[0]?.value

          address_field_one: companyAddress.street
          city: companyAddress.city
          state: companyAddress.state
          country: companyAddress.country
          postal_zip: companyAddress.zip

        app.bidsketchAPI.createClient client
        .then (response) ->
          if response?.id?
            clientId = response.id
            app.exapi.updateCompanyData deal.info.contactPersonId, { bidsketchClientId: clientId }
              .then ->
                Q.resolve clientId
          else
            Q.reject response

      else
        Q.resolve linkedClient.bidsketchClientId

  .then (clientId) ->

    app.bidsketchAPI.createProposal {
      name: deal.name
      description: deal.name
      currency: deal.currency
      client_id: clientId
    }

  .then (proposal) ->
    unless proposal?.id?
      return Q.reject proposal

    fees = deal.fees.item.map (fee) ->
      -> app.bidsketchAPI.createFee proposal.id, prepareFee fee, 'custom'

    fees = fees.concat deal.fees.time.map (fee) ->
      -> app.bidsketchAPI.createFee proposal.id, prepareFee fee, 'hourly'

    Q.all( fees.map (f) -> f() )
    .then ->
      dealId = app.nimbleAPI.getDealIdFromUrl()
      app.exapi.updateCompanyData dealId, { bidsketchProposalId: proposal.id }
      .then ->
        Q.resolve proposal

  .then (proposal) ->
    window.open app.bidsketchAPI.getProposalOpeningSectionsLink(proposal.id), '_blank'
    Q.resolve proposal

module.exports = onCreateProposal
