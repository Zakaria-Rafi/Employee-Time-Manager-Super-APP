import type { InternalAxiosRequestConfig } from "axios";
import { lokiDb } from "./main";
import apiClient from "./services/apiClient";
import type { RequestInQueue } from "./types/loki";
import moment from "moment";
import { useAuthStore } from "./stores/auth";

export async function synchronizeOfflineRequests() {
    const requests = lokiDb.getCollection("queue").find() as Array<RequestInQueue>;

    const apiMethods = {
        POST: apiClient.post,
        PUT: apiClient.put,
        DELETE: apiClient.delete,
    };

    const promises = requests.map(async (request) => {
        try {
            const response = await apiMethods[request.method](request.path, request.body);
            if (response?.status !== 401) {
                lokiDb.getCollection("queue").remove(request);
            }
        } catch(error) {
            lokiDb.getCollection("queue").remove(request);
        }
    });

    Promise.allSettled(promises);
}

function isClockRequest(request: InternalAxiosRequestConfig<any>) {
    return request.method?.toUpperCase() === "POST" && request.url?.includes("/clocks");
}

export function buildRequestInQueue(request: InternalAxiosRequestConfig<any>) {
    if (isClockRequest(request)) {
        const authStore = useAuthStore()
        
        const requestInQueue = { 
            method: "POST", 
            path: request.url + "/offline", 
            body: { time: moment().unix().toString(), status: `${!authStore.user?.currently_working}` }
        }

        if (authStore.user) authStore.user.currently_working = !authStore.user.currently_working

        return requestInQueue
    } else {
        return { 
            method: request.method?.toUpperCase(), 
            path: request.url, 
            body: request.data 
        }
    }
}
