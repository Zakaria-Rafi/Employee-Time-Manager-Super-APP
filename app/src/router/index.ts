import { createRouter, createWebHistory } from "vue-router";
import WorkingTimesView from "@/views/WorkingTimesView.vue";
import DashboardView from "@/views/DashboardView.vue";
import SignInView from "@/views/SignInView.vue";
import { useAuthStore } from "@/stores/auth";
import Manager from "@/views/ManagerView.vue";
import supermanager from "@/views/SuperManagerView.vue";
import { UserRole } from "@/types/userRole";

const router = createRouter({
	history: createWebHistory(import.meta.env.BASE_URL),
	routes: [
		{
			path: "/",
			name: "home",
			redirect: (to) => {
				return { name: "signIn" };
			},
		},
		{
			path: "/signin",
			name: "signIn",
			component: SignInView,
			meta: {
				authorizedRoles: [
					UserRole.ROLE_USER,
					UserRole.ROLE_MANAGER,
					UserRole.ROLE_SUPERMANAGER,
				],
			},
		},
		{
			path: "/dashboard/:userId?",
			name: "dashboard",
			component: DashboardView,
			meta: {
				authorizedRoles: [
					UserRole.ROLE_USER,
					UserRole.ROLE_MANAGER,
					UserRole.ROLE_SUPERMANAGER,
				],
			},
		},
		{
			path: "/workingTimes/:userId?",
			name: "workingTimes",
			component: WorkingTimesView,
			meta: {
				authorizedRoles: [
					UserRole.ROLE_USER,
					UserRole.ROLE_MANAGER,
					UserRole.ROLE_SUPERMANAGER,
				],
			},
		},

		{
			path: "/manager",
			name: "Manager",
			component: Manager,
			meta: {
				authorizedRoles: [UserRole.ROLE_MANAGER, UserRole.ROLE_SUPERMANAGER],
			},
		},

		{
			path: "/supermanager",
			name: "supermanager",
			component: supermanager,
			meta: {
				authorizedRoles: [UserRole.ROLE_MANAGER, UserRole.ROLE_SUPERMANAGER],
			},
		},

		//{
		//    path: '/workingTime/:userId',
		//    name: 'createWorkingTime',
		//    component: CreateWorkingTime,
		//    meta: { authorizedRoles: [ UserRole.ROLE_MANAGER, UserRole.ROLE_SUPERMANAGER ] }
		//},
		//{
		//    path: '/workingTime/:userId/:workingTimeId',
		//    name: 'editWorkingTime',
		//    component: WorkingTime,
		//    meta: { authorizedRoles: [ UserRole.ROLE_MANAGER, UserRole.ROLE_SUPERMANAGER ] }
		//},
		//{
		//    path: "/user",
		//    name: "user",
		//    component: User,
		//    meta: { authorizedRoles: [ UserRole.ROLE_MANAGER, UserRole.ROLE_SUPERMANAGER ] }
		//},
		//{
		//  path: '/manager',
		//  name: 'Manager',
		//  component: Manager,
		//  meta: { authorizedRoles: [ UserRole.ROLE_MANAGER, UserRole.ROLE_SUPERMANAGER ] }
		//}
	],
});

router.beforeEach((to) => {
	const authStore = useAuthStore();

	if (authStore.isAuthenticated) {
		authStore.fetchUser();
	}

	// Auth guard
	if (to.path === "/signin" && authStore.isAuthenticated && authStore.user) {
		return { name: "dashboard" };
	}

	if (to.path !== "/signin" && !authStore.isAuthenticated) {
		return { name: "signIn" };
	} else {
		// Roles guard
		if (to.meta.authorizedRoles && authStore.user) {
			const authorizedRoles = to.meta.authorizedRoles as Array<UserRole>;
			let isUserAuthorized = false;

			for (let userRole of authStore.user.roles) {
				if (authorizedRoles.includes(userRole)) {
					isUserAuthorized = true;
				}
			}

			if (!isUserAuthorized) return { name: "home" };
		}
	}
});

export default router;
