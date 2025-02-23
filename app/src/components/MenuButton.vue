<script setup lang="ts">
import Button from "primevue/button";
import { ref } from "vue";
import TieredMenu from "primevue/tieredmenu";
import { useRouter } from "vue-router";
import { useAuthStore } from "@/stores/auth";
import UserService from "@/services/userService";
import { UserRole } from "@/types/userRole";

const router = useRouter();
const authStore = useAuthStore();
const menu = ref();

const userService = new UserService();
const isManager = authStore.user ? userService.isManager(authStore.user?.roles as UserRole[]) : false
const isSuperManager = authStore.user?.roles.includes(UserRole.ROLE_SUPERMANAGER);

const items = ref([
	{
		label: "Dashboard",
		icon: "pi pi-chart-pie",
		command: async () => {
			await router.push({ name: "dashboard" });
		},
	},
	{
		label: "Planning",
		icon: "pi pi-calendar-clock",
		command: async () => {
			const userId = authStore.user?.id;
			if (!userId) return;
			await router.push({
				name: "workingTimes",
				state: { userId },
			});
		},
	},
	{
		label: "Contact",
		icon: "pi pi-envelope",
		command: async () => {
			const users = await userService.getAll();
			const superManager = users.find((user) =>
				user.roles.includes(UserRole.ROLE_SUPERMANAGER)
			);
			if (superManager) {
				open(`https://teams.microsoft.com/l/chat/0/0?users=${superManager.email}`);
			}
		},
	},
	{
		label: "Logout",
		icon: "pi pi-sign-out",
		command: async () => {
			await authStore.logout();
			await router.push({ name: "signIn" });
		},
	},
]);

if (isManager || isSuperManager) {
	const itemsClone = [...items.value];
	const logoutIndex = itemsClone.findIndex((item) => item.label === "Logout");
	const teamButton = {
		label: "Team",
		icon: "pi pi-users",
		command: async () => {
			router.push({ name: "Manager" })
		},
	};

	itemsClone.splice(logoutIndex, 0, teamButton);
	items.value = itemsClone;
}

if (isSuperManager) {
	const itemsClone = [...items.value];
	const logoutIndex = itemsClone.findIndex((item) => item.label === "Logout");
	const adminButton = {
		label: "Admin",
		icon: "pi pi-wrench",
		command: async () => {
			router.push({ name: "supermanager" })
		},
	};

	itemsClone.splice(logoutIndex, 0, adminButton);
	items.value = itemsClone;
}

const toggle = (event: Event) => {
	menu.value.toggle(event);
};
</script>

<template>
	<Button icon="pi pi-bars" id="menuBtn" @click="toggle"></Button>
	<TieredMenu ref="menu" id="overlay_tmenu" :model="items" popup> </TieredMenu>
</template>

<style>
#menuBtn {
	position: absolute;
	left: 40px;
	top: 20px;
}

#overlay_tmenu {
	@apply bg-secondary;
}

#overlay_tmenu ul li * {
	@apply text-primary font-medium;
}

#overlay_tmenu ul li:last-child * {
	@apply text-red-700;
}
</style>
