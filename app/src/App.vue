<script setup lang="ts">
import { RouterView, useRoute } from "vue-router";
import { synchronizeOfflineRequests } from "./offlineUtils";
import { onMounted, onUnmounted } from "vue";
import MenuButton from "./components/MenuButton.vue";
import Logo from "./components/Logo.vue";
import { useToast } from "primevue/usetoast";

const route = useRoute();
const toast = useToast();
const showOfflineToast = () => {
	toast.add({
		severity: "info",
		summary: "Offline mode",
		detail: "You are currently offline. Data are maybe not up to date.",
		life: 5000,
	});
};

const onlineListener = () => {
	synchronizeOfflineRequests();
};

onMounted(() => {
	addEventListener('online', onlineListener);
	addEventListener('offline', showOfflineToast);
})

onUnmounted(() => {
	removeEventListener('online', onlineListener);
	removeEventListener('offline', showOfflineToast);

})
</script>

<template>
	<Toast />
	<div v-if="route.name !== 'signIn'" id="logoContainer" class="w-full flex justify-center h-28">
		<Logo type="dark"></Logo>
		<MenuButton></MenuButton>
	</div>
	<RouterView />
</template>

<style scoped>
#logoContainer {
	position: relative;
}
</style>
