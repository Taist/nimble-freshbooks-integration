app = require '../app'

Q = require 'q'

getVerifiedAddress = (contact) ->
  if contact.fields?.address?[0]?
    address = JSON.parse contact.fields?.address?[0].value or ""
    if address.city? and address.street?
      return address

  return null

module.exports = (dealInfo) ->
  primaryContactId = dealInfo.deal.related_primary?[0]
  if primaryContactId
    contact = dealInfo.contacts[primaryContactId]

  unless contact?.record_type is 'company'
    return Q.reject 'COMPANY_NOT_FOUND'

  companyHasPeople = contact.children.length > 0
  companyAddress = getVerifiedAddress contact

  if not companyHasPeople and not companyAddress
    return Q.reject 'COMPANY_NO_PEOPLE_NO_ADDRESS'

  unless companyHasPeople
    return Q.reject 'COMPANY_NO_PEOPLE'

  unless companyAddress
    return Q.reject 'COMPANY_ADDRESS_IS_INCOMPLETE'

  companyMembers = []

  Q.all contact.children.map (memberId) ->
    app.nimbleAPI.getContactById memberId

  .then (companyMembersInfo) ->
    companyMembers = companyMembersInfo.map (memberInfo) ->
      member = memberInfo.resources[0]

      return {
        id: member.id
        first_name: member.fields['first name']?[0]?.value
        last_name: member.fields['last name']?[0]?.value
        email: member.fields['email']?[0]?.value
      }

    companyMembers.sort (a, b) ->
      if not a.email? and b.email then 1 else 0

    unless companyMembers[0]?.email
      return Q.reject 'NO_MEMBERS_WITH_EMAIL'
    else
      return Q.resolve { companyAddress, companyMembers, contact }
