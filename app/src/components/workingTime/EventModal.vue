<template>
	<div v-if="isVisible" class="modal-overlay z-10" @click.self="close">
		<div class="modal-content flex gap-4 flex-col">
			<h2>{{ eventTitle }}</h2>
			<p>
				<strong>Start:</strong>
				{{ moment(eventStart).format("DD/MM/YYYY - HH:mm:ss") }}
			</p>
			<p>
				<strong>End:</strong>
				{{ moment(eventEnd).format("DD/MM/YYYY - HH:mm:ss") }}
			</p>
			<div class="flex gap-5">
				<button
					@click="deleteEvent"
					class="bg-red-600 p-3 rounded-md"
					v-if="isWorkingTime && canEdit && !isMobile"
				>
					Delete
				</button>
				<button @click="close" class="bg-primary p-3 rounded-md">Close</button>
			</div>
		</div>
	</div>
</template>

<script setup lang="ts">
import { useAuthStore } from "@/stores/auth";
import { UserRole } from "@/types/userRole";
import moment from "moment";
import { onBeforeUnmount, onMounted, ref } from "vue";

const userRoles = useAuthStore().user?.roles || [];
const isMobile = ref(false);

const canEdit =
	userRoles.includes(UserRole.ROLE_MANAGER) ||
	userRoles.includes(UserRole.ROLE_SUPERMANAGER);

const props = defineProps<{
	isVisible: boolean;
	eventTitle: string;
	eventStart: string;
	eventEnd: string;
	isWorkingTime: boolean;
	eventId: string;
}>();

const emit = defineEmits(["close", "deleteEvent"]);

const close = () => {
	emit("close");
};
// Detect screen size and switch views
const updateViewOnResize = () => {
	const width = window.innerWidth < 768 ? true : false;
	isMobile.value = width;
};

// Attach and detach event listeners
onMounted(() => {
	updateViewOnResize(); // Set the initial view based on screen size
	window.addEventListener("resize", updateViewOnResize); // Listen for screen size changes
});

onBeforeUnmount(() => {
	window.removeEventListener("resize", updateViewOnResize); // Cleanup
});

// Function to delete the event
const deleteEvent = () => {
	emit("deleteEvent", props.eventId); // Emit eventId
	close();
};
</script>

<style scoped>
.modal-overlay {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: rgba(0, 0, 0, 0.5);
	display: flex;
	justify-content: center;
	align-items: center;
}

.modal-content {
	background: white;
	padding: 20px;
	border-radius: 5px;
	box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
}
</style>
