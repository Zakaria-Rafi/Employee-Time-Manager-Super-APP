<script setup lang="ts">
import type { User } from "@/types/user";
import Button from "primevue/button";
import { useRouter } from "vue-router";
import { ref, onMounted, onUnmounted, computed } from "vue";
import ClockManager from "@/services/clockManagerService";

// Get props in script setup
const props = defineProps<{ user: User }>();
const router = useRouter();

const clockManager = new ClockManager(props.user);

const lastClockInTime = ref<string>("N/A");
const clockStatus = computed(() => clockManager.state.clockIn.value ? "Clocked In" : "Clocked Out");
const buttonClockLabel = computed(() => clockManager.state.clockIn.value ? 'Clock out' : 'Clock in')
const timeElapsed = ref<string>("00:00:00");
const showPopup = ref<boolean>(false);
let intervalId: ReturnType<typeof setInterval> | undefined = undefined;

const updateStatus = () => {
	lastClockInTime.value = clockManager.state.startDateTime
		? clockManager.state.startDateTime.toLocaleString()
		: "N/A";
};

const toggleClock = async () => {
	await clockManager.clock(); // Toggle clock in/out
	updateStatus();
	if (clockManager.state.clockIn.value) {
		startTimer();
	} else {
		stopTimer();
		showPopup.value = true; // Show popup when clocking out
	}
};

const startTimer = () => {
	if (intervalId) clearInterval(intervalId);
	intervalId = setInterval(() => {
		if (clockManager.state.startDateTime) {
			const now = new Date().getTime();
			const start = new Date(clockManager.state.startDateTime).getTime();
			const diff = now - start;
			const hours = Math.floor(diff / (1000 * 60 * 60))
				.toString()
				.padStart(2, "0");
			const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
				.toString()
				.padStart(2, "0");
			const seconds = Math.floor((diff % (1000 * 60)) / 1000)
				.toString()
				.padStart(2, "0");
			timeElapsed.value = `${hours}:${minutes}:${seconds}`;
		}
	}, 1000);
};

const stopTimer = () => {
	if (intervalId) clearInterval(intervalId);
};

const closePopup = () => {
	showPopup.value = false;
	timeElapsed.value = "00:00:00"; // Reset the timer when closing
};

onMounted(async () => {
	await clockManager.refresh(); // Fetch current clock state when component mounts
	updateStatus();
	if (clockManager.state.clockIn.value) {
		startTimer(); // If clocked in, start the timer
	}
});

onUnmounted(() => {
	stopTimer(); // Clear the interval when the component is destroyed
});

async function redirectToEditUser() {
	await router.push({ name: "UserDetail", params: { id: props.user.id} });
}
</script>

<template>
	<div id="clockInOut">
		<p id="clockInOutTitle" class="font-medium text-primary mb-2">Time clock</p>

		<div
			id="clockInOutContainer"
			v-if="props.user"
			class="bg-primary text-secondary flex flex-col justify-around gap-y-4 p-6"
		>
			<p id="clockStatus" class="">
				Status: <b id="clockStatusValue">{{ clockStatus }}</b>
			</p>
			<p id="lastClockIn" v-if="clockManager.state.clockIn.value">
				Last Clock In: {{ lastClockInTime }}
			</p>
			<p id="timeElapsed">Time Elapsed: {{ timeElapsed }}</p>
			<Button
				id="clockBtn"
				@click="toggleClock"
				:label="buttonClockLabel"
				:class="
					clockManager.state.clockIn.value
						? 'p-button-danger hoverText'
						: 'p-button-success hoverText'
				"
			/>
		</div>
	</div>
</template>

<style scoped>
#clockInOutContainer {
	height: 32vh;
	border-radius: 20px;
	position: relative;
}

#clockInOutEditBtn {
	position: absolute;
	top: 20px;
	right: 20px;
}

.clockInOutValue {
	@apply font-bold text-base;
}

#clockInOutTitle {
	font-size: 1.5rem;
}
.p-button-danger {
	background-color: red;
}
.p-button-success {
	@apply text-primary bg-secondary;
}
.hoverText:hover {
	@apply text-secondary;
}
</style>
