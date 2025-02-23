/// <reference types="cypress" />

import signinPage from "../pom/signin"

// ***********************************************
// This example commands.ts shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })
//
// declare global {
//   namespace Cypress {
//     interface Chainable {
//       login(email: string, password: string): Chainable<void>
//       drag(subject: string, options?: Partial<TypeOptions>): Chainable<Element>
//       dismiss(subject: string, options?: Partial<TypeOptions>): Chainable<Element>
//       visit(originalFn: CommandOriginalFn, url: string, options: Partial<VisitOptions>): Chainable<Element>
//     }
//   }
// }

declare global {
    namespace Cypress {
      interface Chainable {
        login(email: string, password: string): Chainable<void>
      }
    }
  }

Cypress.Commands.add('login', (email: string, password: string) => {
    cy.visit('/signin')
    cy.intercept('POST', '/api/login').as('signin')
    
    cy.get(signinPage.emailInputSelector).type(email)
    cy.get(signinPage.pwdInputSelector).type(password)
    cy.get(signinPage.connectBtnSelector).click()
    
    cy.wait('@signin').then((apiCall) => {
        expect(apiCall.response?.statusCode).to.equal(200)
        cy.url().should('include', '/dashboard')
    })
})

export {}
