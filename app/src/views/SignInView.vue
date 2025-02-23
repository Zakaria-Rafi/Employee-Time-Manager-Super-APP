<script setup lang="ts">
import Logo from "@/components/Logo.vue";
import InputText from "primevue/inputtext";
import Button from "primevue/button";
import { ref } from "vue";
import { useAuthStore } from "@/stores/auth";
import { useRouter } from "vue-router";
import Toast from "primevue/toast";
import { useToast } from "primevue/usetoast";

const authStore = useAuthStore();
const router = useRouter();

const emailRef = ref("");
const passwordRef = ref("");

const toast = useToast();

async function login() {
	try {
		await authStore.login(emailRef.value, passwordRef.value);
		if (authStore.user) {
			router.push({ name: "dashboard" });
		}
	} catch (err) {
		toast.add({
			severity: "error",
			summary: "Connection failed",
			detail: "Email or password invalid",
			life: 3000,
		});
	}
}
</script>

<template>
	<Toast id="signinErrorToast"/>

    <div class="flex h-screen flex-col">
        <div class="flex h-full flex-1">
            <div class="relative md:block hidden width-0 flex-1 bg-primary">
				<div class="flex justify-center items-center h-full w-full">
					<Logo type="light" />
				</div>
            </div>
			<div class="flex flex-1 flex-col justify-center px-4 px-12 px-6 px-20 px-24">
                <div class="mx-auto w-full max-w-96 w-96">
                    <div>
						<Logo type="dark" class="md:hidden flex mx-auto justify-center items-center" />
                        <h1 id="signInTitle"class="text-xl font-bold leading-9 tracking-tight text-center text-gray-900">
                            Login to your TimeManager account
                        </h1>
                    </div>
                    <div class="mt-10">
                        <form class="w-full max-w-md space-y-4 md:space-y-6 xl:max-w-xl" @submit.prevent="login">
							<div>
								<label id="emailLabel" for="email" class="block mb-2 text-sm font-medium text-gray-900 dark:text-gray-300">Email</label>
								<input id="emailInput" type="email" placeholder="email@address.com" v-model="emailRef" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-500 focus:border-primary-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white" required>
							</div>
							<div>
								<label id="passwordLabel" for="password" class="block mb-2 text-sm font-medium text-gray-900 dark:text-gray-300">Password</label>
								<input id="passwordInput" type="password" placeholder="*********" v-model="passwordRef" class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-primary-500 focus:border-primary-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white" required>
							</div>
							<Button id="connectBtn" class="bg-primary w-full" type="submit">Connect</Button>
						</form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

