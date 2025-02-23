import apiClient from "@/services/apiClient";
import { useAuthStore } from "@/stores/auth";
import type { Clock } from "@/types/clock";
import type { User } from "@/types/user";
import { computed, ref, type Ref } from "vue";

interface ClockManagerState {
	startDateTime: Date | null;
	clockIn: Ref<boolean>;
}

class ClockManager {
	user: User;
	state: ClockManagerState;

	constructor(user: User) {
		this.user = user;
		this.state = {
			startDateTime: null,
			clockIn: ref<boolean>(user.currently_working ?? false),
		};
	}
	async getLastClock(userId: number): Promise<Clock> {
		const response = await apiClient.get(`/clocks/${userId}`);
		return response.data.items;
	}

	// Method to refresh the current clock state
	async refresh(): Promise<void> {
		try {
			const response = await apiClient.get<Clock>(`/clocks/${this.user.id}`);

			if (response.data.status) {
				this.state.startDateTime = new Date(response.data.time);
				this.state.clockIn.value = response.data.status;
			} else {
				this.state.startDateTime = null;
				this.state.clockIn.value = false;
			}
		} catch (error) {
			console.error("Error fetching clock status:", error);
		}
	}

	// Method to toggle clock in/out
	async clock(): Promise<void> {
		try {
			await this.refresh();
			const response = await apiClient.post<Clock>(`/clocks/${this.user.id}`);

			// Assuming response.data contains the necessary fields
			if (response.data.status) {
				this.state.startDateTime = new Date(response.data.time);
				this.state.clockIn.value = response.data.status;
			} else {
				this.state.startDateTime = null;
				this.state.clockIn.value = false;
			}
		} catch (error) {
			this.state.clockIn.value = !this.state.clockIn.value;
		}
	}

	// methode to update the clock time and to_check
	// /clocks/:userId/clock/:clockId
	async updateClockTime(userId: number, clockId: number, time: number, status: boolean): Promise<Clock | undefined> {
		try {
			const response = await apiClient.put(`/clocks/${userId}/clock/${clockId}`, {time: time.toString() , status: status.toString()});
			console.log("response", response);
			return response.data;
		}
		catch (error) {
			console.error("Error updating clock time:", error);
			return undefined;
		}
	}
}

export default ClockManager;
