import { lokiDb } from "@/main";
import { useAuthStore } from "@/stores/auth";
import { buildRequestInQueue } from "@/offlineUtils";
import axios from "axios";

const apiClient = axios.create({
	baseURL: "http://localhost:4000/api",
	// baseURL: "http://XXX.XX.XXX.XXX:4000/api", // Replace with your elixir IP for cordova
	headers: {
		"Content-Type": "application/json",
	},
});


apiClient.interceptors.request.use((request) => {
	if (navigator.onLine) {
		const authStore = useAuthStore()
		if (authStore.csrfToken) {
			request.headers.set('X-CSRF-Token', authStore.csrfToken);
		}

		if (authStore.token) {
			request.headers.Authorization = `Bearer ${authStore.token}`
		}
	
		return request
	} else {
		if (request.method?.toUpperCase() !== "GET" && request.url !== "/login") {
			const requestInQueue = buildRequestInQueue(request)
			lokiDb.getCollection("queue").insertOne(requestInQueue)
		}
		const controller = new AbortController();
		request.signal = controller.signal
		controller.abort()
		return request
	}
})

apiClient.interceptors.response.use(response => {
	return response;
 }, async (error) => {
   if (error.response.status === 401) {
	// Expired JWT => refresh page, which will redirect to /signin
	const authStore = useAuthStore()
	authStore.user = null
	authStore.token = ""
	window.location.reload()
   }
   return error;
 });

export default apiClient;
