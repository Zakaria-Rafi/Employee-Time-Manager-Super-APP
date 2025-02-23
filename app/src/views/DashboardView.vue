<script setup lang="ts">
import { ref, onMounted } from "vue";
import type { User } from "@/types/user";
import UserService from "@/services/userService";
import UserInfos from "@/components/dashboard/UserInfos.vue";
import ChartsManager from "@/components/dashboard/ChartsManager.vue";
import { ChartType } from "@/types/ChartType";
import ClockInOut from "@/components/dashboard/ClockInOut.vue";
import Logo from "@/components/Logo.vue";
import MenuButton from "@/components/MenuButton.vue";
import { useAuthStore } from '@/stores/auth'
import { useRoute } from "vue-router";
import { UserRole } from "@/types/userRole";

const authStore = useAuthStore();
const route = useRoute()
const user = ref<User>()

const userService = new UserService()

const areInSameTeam = async (managerId: number, wantedUserId: number) => {
	const managerTeams = await userService.getUserTeams(managerId)
	const userTeams = await userService.getUserTeams(wantedUserId)
	return userTeams.some(userTeam => {
		return managerTeams.find(managerTeam => managerTeam.id === userTeam.id) ? true : false
	})
}

onMounted(async () => {
	const userId = route.params.userId as string
	const isCurrentUserManager = userService.isManager(authStore.user?.roles as UserRole[])
	
	const isSuperManager = authStore.user?.roles.includes(UserRole.ROLE_SUPERMANAGER) 
	
	if (userId && isSuperManager) {
		user.value = await userService.get(parseInt(userId))
	} else if (userId && isCurrentUserManager) {
		// Check if user is in the manager's team
		const isUserInManagerTeam = await areInSameTeam(authStore.user?.id as number, parseInt(userId))
		
		// Check that wanted user is employee
		const wantedUser = await userService.get(parseInt(userId))
		const isWantedUserEmployee = userService.isEmployee(wantedUser.roles)

		if (isUserInManagerTeam && isWantedUserEmployee) user.value = wantedUser
		else user.value = authStore.user as User
	} else {
		// User is employee, show his dashboard
		user.value = authStore.user as User
	}
})
</script>

<template>
	<div
		v-if="user"
		id="dashboardContent"
		class="grid grid-cols-1 lg:grid-cols-10"
	>
		<div class="w-full sm:max-w-sm mx-auto lg:col-span-4">
			<!-- TOP LEFT : User Informations -->
			<UserInfos :user="user"></UserInfos>
			<!-- BOTTOM LEFT : Clock in/out -->
			<ClockInOut class="mt-4" :user="user"></ClockInOut>
		</div>

		<div class="w-full sm:max-w-sm mx-auto lg:max-w-2xl lg:col-span-6">
			<!-- TOP RIGHT : Graph -->
			<ChartsManager
				id="barChart"
				:userId="user.id"
				:chartType="ChartType.BAR"
			></ChartsManager>
			<!-- BOTTOM RIGHT : 2 diagrams / graphs -->
			<div id="" class="grid grid-cols-1 grid-cols-12 gap-4 mt-4">
				<ChartsManager
					id="doughnutDayChart"
					class="col-span-6"
					:userId="user.id"
					:chartType="ChartType.DOUGHNUT_DAY"
				></ChartsManager>
				<ChartsManager
					id="doughnutWeekChart"
					class="col-span-6"
					:userId="user.id"
					:chartType="ChartType.DOUGHNUT_WEEK"
				></ChartsManager>
			</div>
		</div>
	</div>
</template>

<style scoped>
</style>
