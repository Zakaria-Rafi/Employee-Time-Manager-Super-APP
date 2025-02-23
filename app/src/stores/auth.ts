import { ref, computed } from 'vue';
import { defineStore } from 'pinia';
import AuthService from '@/services/authService';
import UserService from '@/services/userService';
import type { User } from '@/types/user';

export const useAuthStore = defineStore('auth', () => {
    const authService = new AuthService();
    const userService = new UserService();

    const user = ref<User | null>(null);
    const token = ref<string>("");
    const csrfToken = ref<string>("");
    const isAuthenticated = computed(() => !!user.value);

    async function login(email: string, password: string) {
        try {
            const loginResponse = await authService.login(email, password);
            token.value = loginResponse.data.token;
            csrfToken.value = loginResponse.data.csrf_token;

            const userResponse = await userService.me();
            user.value = userResponse.data;
        } catch (error) {
            console.error('Login failed:', error);
            throw error;
        }
    }

    async function fetchUser() {
        if (user.value?.id) {
            try {
                const userResponse = await userService.get(user.value.id);
                user.value = userResponse;
            } catch (error) {
                console.error('Fetch user failed:', error);
                throw error;
            }
        } else {
            console.warn('No user logged in.');
        }
    }

    async function logout() {
        try {
            await authService.logout();
            user.value = null;
            token.value = "";
        } catch (error) {
            console.error('Logout failed:', error);
            throw error;
        }
    }

    return { user, token, csrfToken, isAuthenticated, login, logout, fetchUser };
}, {
    persist: true
});
