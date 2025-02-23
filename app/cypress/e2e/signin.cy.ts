import signInPOM from '../pom/signin'

describe('Sign in page tests', () => {
    beforeEach(() => {
        cy.visit('/signin')
    })

    describe('UI', () => {
        it ('Logo', () => {
          cy.get(signInPOM.logo).should('be.visible')
        })

        it ('Form', () => {
          cy.get(signInPOM.titleSelector).should('be.visible').and('contain.text', signInPOM.titleTxt)
          
          cy.get(signInPOM.emailLabelSelector).should('be.visible').and('have.text', signInPOM.emailLabelTxt)
          cy.get(signInPOM.emailInputSelector).should('be.visible')
          
          cy.get(signInPOM.pwdLabelSelector).should('be.visible').and('have.text', signInPOM.pwdLabelTxt)
          cy.get(signInPOM.pwdInputSelector).should('be.visible')

          cy.get(signInPOM.connectBtnSelector).should('be.visible').and('have.text', signInPOM.connectBtnTxt)
        })
    })

    describe('Sign in', () => {
      it('CP - Sign in with valid credantials redirects us to dashboard', () => {
        cy.intercept('POST', '/api/login').as('signin')

        cy.get(signInPOM.emailInputSelector).type('supermanager@epitech.eu')
        cy.get(signInPOM.pwdInputSelector).type('azertyuiop')
        cy.get(signInPOM.connectBtnSelector).click()

        cy.wait('@signin').then((apiCall) => {
          expect(apiCall.response?.statusCode).to.equal(200)
          cy.url().should('include', '/dashboard')
        })
      })

      it('NP - Sign in with invalid credantials should display an error toast', () => {
        cy.intercept('POST', '/api/login').as('signin')

        cy.get(signInPOM.emailInputSelector).type('blabla@epitech.eu')
        cy.get(signInPOM.pwdInputSelector).type('abc')
        cy.get(signInPOM.connectBtnSelector).click()

        cy.wait('@signin').then((apiCall) => {
          expect(apiCall.response?.statusCode).to.equal(400)
          cy.wait(500)
          cy.get(signInPOM.errorToast).should('be.visible')
            .and('contain.text', 'Connection failed')
            .and('contain.text', 'Email or password invalid')
        })
      })
    })
  })
  