import menuPOM from "../pom/menu"
import dashboardPOM from "../pom/dashboard"

describe('Dashboard page tests', () => {
    const supermanager = Cypress.env('credentials').supermanager

    beforeEach(() => {
        cy.login(supermanager.email, supermanager.password)
    })

    describe('UI', () => {
        it ('Logo', () => {
          cy.get(dashboardPOM.logo).should('be.visible')
        })

        it('Menu', () => {
          cy.get(menuPOM.button).should('be.visible')
          cy.get(menuPOM.button).click()
          cy.get(menuPOM.list.container).should('be.visible')
        })

        it('User infos', () => {
          cy.get(dashboardPOM.userInfos.container).should('be.visible')
          
          cy.get(dashboardPOM.userInfos.titleSelector).should('be.visible')
            .and('contain.text', dashboardPOM.userInfos.titleTxt)
          
          cy.get(dashboardPOM.userInfos.editBtn).should('be.visible')
          
          cy.get(dashboardPOM.userInfos.panel.container).should('be.visible')
          
          cy.get(dashboardPOM.userInfos.panel.username.container).should('be.visible')
          cy.get(dashboardPOM.userInfos.panel.username.labelSelector).should('be.visible')
            .and('contain.text', dashboardPOM.userInfos.panel.username.labelTxt)
          cy.get(dashboardPOM.userInfos.panel.username.value).should('be.visible')

          cy.get(dashboardPOM.userInfos.panel.email.container).should('be.visible')
          cy.get(dashboardPOM.userInfos.panel.email.labelSelector).should('be.visible')
            .and('contain.text', dashboardPOM.userInfos.panel.email.labelTxt)
          cy.get(dashboardPOM.userInfos.panel.email.value).should('be.visible')

          cy.get(dashboardPOM.userInfos.panel.lastLogin.container).should('be.visible')
          cy.get(dashboardPOM.userInfos.panel.lastLogin.labelSelector).should('be.visible')
            .and('contain.text', dashboardPOM.userInfos.panel.lastLogin.labelTxt)
          cy.get(dashboardPOM.userInfos.panel.lastLogin.value).should('be.visible')
        })

        it('Edit user infos popup', () => {
          const editUserPopup = dashboardPOM.editUserPopup
          cy.get(dashboardPOM.userInfos.editBtn).click()

          cy.get(editUserPopup.container).should('be.visible')
          cy.get(editUserPopup.titleSelector).should('be.visible')
            .and('contain.text', editUserPopup.titleTxt)

          cy.get(editUserPopup.usernameLabelSelector).should('be.visible')
            .and('contain.text', editUserPopup.usernameLabelTxt)
          cy.get(editUserPopup.usernameInput).should('be.visible')

          cy.get(editUserPopup.emailLabelSelector).should('be.visible')
            .and('contain.text', editUserPopup.emailLabelTxt)
          cy.get(editUserPopup.emailInput).should('be.visible')

          cy.get(editUserPopup.pwdLabelSelector).should('be.visible')
            .and('contain.text', editUserPopup.pwdLabelTxt)
          cy.get(editUserPopup.pwdInput).should('be.visible')

          cy.get(editUserPopup.closeBtn).should('be.visible')
          cy.get(editUserPopup.updateBtn).should('be.visible')
          cy.get(editUserPopup.deleteBtn).should('be.visible')
        })

        it('Delete user popup', () => {
          const deletePopup = dashboardPOM.editUserPopup.deleteUserPopup
          cy.get(dashboardPOM.userInfos.editBtn).click()
          cy.get(dashboardPOM.editUserPopup.deleteBtn).click()

          cy.get(deletePopup.container).should('be.visible')
          
          cy.get(deletePopup.titleSelector).should('be.visible')
            .and('contain.text', deletePopup.titleTxt)
          
          cy.get(deletePopup.contentSelector).should('be.visible')
            .and('contain.text', deletePopup.contentTxt)

          cy.get(deletePopup.cancelBtn).should('be.visible')
          cy.get(deletePopup.confirmBtn).should('be.visible')
          cy.get(deletePopup.closeBtn).should('be.visible')
        })

        it('Clock', () => {
          cy.get(dashboardPOM.clock.container).should('be.visible')

          cy.get(dashboardPOM.clock.titleSelector).should('be.visible')
            .and('contain.text', dashboardPOM.clock.titleTxt)

          cy.get(dashboardPOM.clock.panel.status.container).should('be.visible')
          cy.get(dashboardPOM.clock.panel.status.value).should('be.visible')

          cy.get(dashboardPOM.clock.panel.button).then($btn => {
            const text = $btn.text()
            if (text.includes("Clock in")) {
              cy.get(dashboardPOM.clock.panel.status.value).should('contain.text', "Clocked Out")
              cy.get(dashboardPOM.clock.panel.button).click()
              cy.get(dashboardPOM.clock.panel.status.value).should('contain.text', "Clocked In")
              cy.get(dashboardPOM.clock.panel.lastClockIn).should('be.visible')
              cy.get(dashboardPOM.clock.panel.button).click()
            } else {
              cy.get(dashboardPOM.clock.panel.status.value).should('contain.text', "Clocked In")
              cy.get(dashboardPOM.clock.panel.lastClockIn).should('be.visible')
              cy.get(dashboardPOM.clock.panel.button).click()
            }
          })
        })

        it('Bar chart', () => {
          cy.get(dashboardPOM.barChart.titleSelector).should('be.visible')
            .and('contain.text', dashboardPOM.barChart.titleTxt)

          cy.get(dashboardPOM.barChart.panel.container).should('be.visible')
          cy.get(dashboardPOM.barChart.panel.chart).should('be.visible')
        })

        it('Doughnut Day chart', () => {
          cy.get(dashboardPOM.dayChart.titleSelector).should('be.visible')
            .and('contain.text', dashboardPOM.dayChart.titleTxt)

          cy.get(dashboardPOM.dayChart.panel.container).should('be.visible')
          cy.get(dashboardPOM.dayChart.panel.chart).should('be.visible')
        })

        it('Doughnut Week chart', () => {
          cy.get(dashboardPOM.weekChart.titleSelector).should('be.visible')
            .and('contain.text', dashboardPOM.weekChart.titleTxt)

          cy.get(dashboardPOM.weekChart.panel.container).should('be.visible')
          cy.get(dashboardPOM.weekChart.panel.chart).should('be.visible')
        })
    })

    describe('User infos', () => {
      it('Update user infos', () => {
        const editUserPopup = dashboardPOM.editUserPopup
        const newUsername = "JeSaisPas"
        cy.intercept('PUT', '/api/users/*').as('updateUser')

        cy.get(dashboardPOM.userInfos.editBtn).click()
        cy.get(editUserPopup.usernameInput).clear().type(newUsername)
        cy.get(editUserPopup.pwdInput).clear().type(supermanager.password)
        cy.get(editUserPopup.updateBtn).click()

        cy.wait('@updateUser').then(() => {
          cy.get(editUserPopup.container).should('not.exist')
        })
      })

      it('Delete Account', () => {
        const deletePopup = dashboardPOM.editUserPopup.deleteUserPopup
        cy.intercept('DELETE', '/api/users/*', {
          statusCode: 200,
        }).as('deleteAccount')

        cy.get(dashboardPOM.userInfos.editBtn).click()
        cy.get(dashboardPOM.editUserPopup.deleteBtn).click()
        
        cy.get(deletePopup.cancelBtn).click()
        cy.get(deletePopup.container).should('not.exist')
        
        cy.get(dashboardPOM.editUserPopup.deleteBtn).click()

        cy.get(deletePopup.confirmBtn).click()

        cy.wait('@deleteAccount').then(() => {
          cy.url().should('eq', Cypress.config().baseUrl + '/signin')
        })
      })
    })

    describe('Clock', () => {

      it('Clock in/out', () => {
        // Setup clock in/out
        cy.get(dashboardPOM.clock.panel.button).then($btn => {
          const text = $btn.text()
          if (text.includes("Clock out")) {
            cy.get(dashboardPOM.clock.panel.button).click()
          }
        })

        // Clock in
        cy.intercept('POST', '/api/clocks/*').as('clock')
        cy.get(dashboardPOM.clock.panel.button).click()
        
        cy.wait('@clock').then(() => {
          cy.get(dashboardPOM.clock.panel.status.value).should('contain.text', "Clocked In")
          cy.get(dashboardPOM.clock.panel.lastClockIn).should('be.visible')
        })

        // Clock out
        cy.get(dashboardPOM.clock.panel.button).click()
        cy.wait('@clock').then(() => {
          cy.get(dashboardPOM.clock.panel.status.value).should('contain.text', "Clocked Out")
          cy.get(dashboardPOM.clock.panel.lastClockIn).should('not.exist')
        })
      })
    })
  })
  