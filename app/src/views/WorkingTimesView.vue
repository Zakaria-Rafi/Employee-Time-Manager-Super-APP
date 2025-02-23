<script setup lang="ts">
import { useRoute } from "vue-router";
import Calendar from "@/components/workingTime/Calendar.vue";
import Logo from "@/components/Logo.vue";
import MenuButton from "@/components/MenuButton.vue";
import { onMounted, ref } from "vue";
import { useAuthStore } from "@/stores/auth";
import { UserRole } from "@/types/userRole";
import UserService from "@/services/userService";

const route = useRoute();

const authStore = useAuthStore();
const isManager =
	authStore.user?.roles.includes(UserRole.ROLE_MANAGER) ||
	authStore.user?.roles.includes(UserRole.ROLE_SUPERMANAGER);

const userId = ref<number>();

const userService = new UserService()

const areInSameTeam = async (managerId: number, wantedUserId: number) => {
	const managerTeams = await userService.getUserTeams(managerId)
	const userTeams = await userService.getUserTeams(wantedUserId)
	return userTeams.some(userTeam => {
		return managerTeams.find(managerTeam => managerTeam.id === userTeam.id) ? true : false
	})
}

onMounted(async () => {
	const givenUserId = parseInt(route.params.userId as string);

	if (givenUserId && userId.value !== authStore.user?.id && isManager) {
		if (authStore.user?.roles.includes(UserRole.ROLE_SUPERMANAGER)) {
			userId.value = givenUserId;
		} else {
			const isSameTeam = await areInSameTeam(authStore.user?.id as number, givenUserId);
			const wantedUser = await userService.get(givenUserId);
			const isWantedUserEmployee = userService.isEmployee(wantedUser.roles);

			if (isWantedUserEmployee && isSameTeam) userId.value = givenUserId;
			else userId.value = authStore.user?.id as number;
		}
	} else {
		userId.value = authStore.user?.id as number;
	}
});
</script>

<template>
	<Calendar v-if="userId" :userId="userId"></Calendar>
</template>

<style scoped></style>
