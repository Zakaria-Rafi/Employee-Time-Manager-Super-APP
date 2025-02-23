import { defineConfig } from 'cypress'

export default defineConfig({
  e2e: {
    specPattern: 'cypress/e2e/**/*.{cy,spec}.{js,jsx,ts,tsx}',
    baseUrl: 'http://localhost',
    viewportWidth: 1920,
    viewportHeight: 1080,
  },
  env: {
    credentials: {
      employee: {
        email: "employee@epitech.eu",
        password: "azertyuiop",
      },
      manager: {
        email: "manager@epitech.eu",
        password: "azertyuiop",
      },
      supermanager: {
        email: "supermanager@epitech.eu",
        password: "azertyuiop",
      },
    }
  },
  watchForFileChanges: false
})
