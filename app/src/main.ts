import "./assets/main.css";

import { createApp } from "vue";
import { createPinia } from "pinia";
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'

import App from "./App.vue";
import router from "./router";
import PrimeVue from "primevue/config";
// @ts-ignore
import Aura from "./presets/aura"

import "./assets/tailwind.css";
import "primeicons/primeicons.css";
import ToastService from 'primevue/toastservice';
import Loki from "lokijs"

const app = createApp(App);
app.use(ToastService);

const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)

app.use(pinia);
app.use(PrimeVue, {
	unstyled: true,
	pt: Aura,
});

export const lokiDb = new Loki("lokiDb", {
	autosave: true,
	autosaveInterval: 5000
})

lokiDb.loadDatabase({}, function() {
    let queue = lokiDb.getCollection("queue");
    if (!queue) {
        lokiDb.addCollection("queue");
    }
});

app.use(router);

app.mount("#app");
