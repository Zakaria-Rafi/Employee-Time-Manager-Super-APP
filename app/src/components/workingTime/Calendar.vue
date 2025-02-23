<template>
	<div>
		<h4 class="text-lg">Total Working Time on this period: <b>{{ totalWorkingTime }} h</b></h4 class="text-lg">
		<div class="m-4 shadow-md ">
			<FullCalendar ref="calendarRef" :options="calendarOptions" />
		</div>
		<EventModal
			v-if="showModal"
			:isVisible="showModal"
			:eventTitle="selectedEvent?.title"
			:eventStart="selectedEvent?.start"
			:eventEnd="selectedEvent?.end"
			:isWorkingTime="selectedEvent?.isWorkingTime"
			:eventId="selectedEvent?.id"
			@close="showModal = false"
			@deleteEvent="deleteEvent"
		/>
	</div>
</template>

<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, type Ref } from "vue";
import FullCalendar from "@fullcalendar/vue3";
import dayGridPlugin from "@fullcalendar/daygrid";
import timeGridPlugin from "@fullcalendar/timegrid";
import interactionPlugin from "@fullcalendar/interaction";
import WorkingTimeService from "@/services/WorkingTimeService";
import clockManagerService from "@/services/clockManagerService";
import UserService from "@/services/userService";
import type { WorkingTime } from "@/types/workingTime";
import type { workingtimeClock } from "@/types/workingtimesClocks";
import moment from "moment";
import EventModal from "./EventModal.vue";
import type { calendarEvent } from "@/types/calendarEvent";
import { useAuthStore } from "@/stores/auth";
import { UserRole } from "@/types/userRole";
import type { User } from "@/types/user";

// Assume the userId is passed as a prop
const props = defineProps<{ userId: number }>();

const userRoles = useAuthStore().user?.roles || [];

const totalWorkingTime: any = ref(0);

const isMobile = ref(false);

const canEdit =
	userRoles.includes(UserRole.ROLE_MANAGER) ||
	userRoles.includes(UserRole.ROLE_SUPERMANAGER);

const showModal = ref(false);
const selectedEvent: any = ref(null);
const calendarRef = ref<InstanceType<typeof FullCalendar> | null>(null);
const workingTimeService = new WorkingTimeService();
const userService = new UserService();
const currentUser: Ref<User | null> = ref(null);
let clockManager: clockManagerService | null = null;

// Load working times for the current week
const loadWorkingTimes = async (start: string, end: string) => {
	try {
		const period = {
			start: moment(start).unix().toString(),
			end: moment(end).unix().toString(),
		};

		const workingTimes = await workingTimeService.getAll(props.userId, period);
		const workingtimesClocks = await workingTimeService.getClocks(
			props.userId,
			period,
		);

		const calendarEvents: Array<calendarEvent> = [];

		// Process Working Times
		workingTimes.forEach((workingTime: WorkingTime) => {
			calendarEvents.push({
				id: workingTime.id.toString(),
				title: "Working Time",
				start: workingTime.start,
				end: workingTime.end,
				color: "blue",
				allDay: false,
			});
		});

		// Process Clocks
		workingtimesClocks.forEach((workingtimeClock: workingtimeClock) => {
			let clockInEvent: any = null;

			workingtimeClock.clocks.forEach((clock) => {
				if (clock.status) {
					// Clock In
					clockInEvent = clock;
				} else if (clockInEvent) {
					// Clock Out (pair it with the previous Clock In)
					calendarEvents.push({
						id: `${clockInEvent.id}/${clock.id}`, // Combine clockIn and clockOut IDs
						title: "Working Session",
						start: clockInEvent.time,
						end: clock.time,
						color: (clockInEvent.to_check || clock.to_check)?"orange": "green",
						allDay: false,
						toValidate: clockInEvent.to_check || clock.to_check,
					});
					clockInEvent = null; // Reset after pairing
				}
			});

			// Handle ongoing sessions (Clock In without Clock Out)
			const lastClock = workingtimeClock.clocks[workingtimeClock.clocks.length - 1];
			if (lastClock && lastClock.status) {
				calendarEvents.push({
					id: `current-${lastClock.id}`,
					title: "Working Session (Ongoing)",
					start: lastClock.time,
					end: moment().toISOString(),
					color: "red",
					allDay: false,
					toValidate: true,
				});
			}
		});

		// Update the calendar with events
		calendarOptions.value.events = calendarEvents;
		calculateTotalWorkingTime();

		console.log("Working Times loaded successfully");
		console.log(calendarEvents);
	} catch (error) {
		console.error(error);
	}
};


// Handle time range select (for creating new working times)
const handleSelect = async (info: any) => {
	if (!canEdit || isMobile.value)  {
		return;
	}
	const start = moment(info.startStr).unix().toString();
	const end = moment(info.endStr).unix().toString();

	// Call service to create a new working time
	const newEvent = await workingTimeService.create(props.userId, start, end);

	// Add the new working time to the calendar
	calendarOptions.value.events.push({
		id: newEvent.id.toString(),
		title: "Working Time",
		start: newEvent.start,
		end: newEvent.end,
		allDay: false,
	});
	refreshCalendar();
};

// Handle event drop (when dragging an event)
const handleEventDrop = async (info: any) => {
	const updatedEvent = {
		start: moment(info.event.startStr).unix().toString(),

		end: moment(info.event.endStr).unix().toString(),
	};
	if (info.event.title === "Working Session (Ongoing)") {
		return;
	}
	else if (info.event.title === "Working Session") {
		const [clockInId, clockOutId] = info.event.id.split("/");
		await clockManager?.updateClockTime(props.userId , clockInId , moment(info.event.startStr).unix(),true);

		await clockManager?.updateClockTime(props.userId , clockOutId , moment(info.event.endStr).unix(),false);
	} else if (info.event.title === "Working Time") {
	await workingTimeService.update(info.event.id, updatedEvent);
	}
	refreshCalendar();
};

// Handle event resize (when resizing an event)
const handleEventResize = async (info: any) => {
	const updatedEvent = {
		start: moment(info.event.startStr).unix().toString(),

		end: moment(info.event.endStr).unix().toString(),
	};
	if (info.event.title === "Working Session (Ongoing)") {
		return;
	}
	else if (info.event.title === "Working Session") {
		const [clockInId, clockOutId] = info.event.id.split("/");
		await clockManager?.updateClockTime(props.userId , clockInId , moment(info.event.startStr).unix(),true);
		await clockManager?.updateClockTime(props.userId , clockOutId , moment(info.event.endStr).unix(),false);
	} else if (info.event.title === "Working Time") {
	await workingTimeService.update(info.event.id, updatedEvent);
	}
	refreshCalendar();
};

// Function to handle event click
const handleEventClick = (info: any) => {
	const isWorkingTime = info.event.title === "Working Time"; // Adjust as needed
	selectedEvent.value = {
		id: info.event.id, // Store the event ID
		title: info.event.title,
		start: info.event.start.toISOString(),
		end: info.event.end ? info.event.end.toISOString() : "Ongoing",
		isWorkingTime: isWorkingTime,
	};

	showModal.value = true; // Show the modal
	refreshCalendar();
};

// Function to delete the event
const deleteEvent = async (eventId: string) => {
	// Receive the event ID
	await workingTimeService.delete(parseInt(eventId, 10));
	refreshCalendar();
};
// Handle calendar date changes
const handleDatesSet = async (dateInfo: any) => {
	const start = dateInfo.startStr;
	const end = dateInfo.endStr;
	await loadWorkingTimes(start, end);
};

const refreshCalendar = () => {
	// Use the calendarRef to access the current date range
	if (calendarRef.value) {
		const calendarApi = calendarRef.value.getApi();
		const currentStart = calendarApi.view.currentStart.toISOString();
		const currentEnd = calendarApi.view.currentEnd.toISOString();
		handleDatesSet({ startStr: currentStart, endStr: currentEnd });
	}
};

const calculateTotalWorkingTime = () => {
	const calendarApi = calendarRef.value?.getApi();
	if (calendarApi) {
		const events = calendarApi.getEvents();
		let totalDuration = 0;

		events.forEach((event) => {
			if (event.start && event.end && event.title === "Working Time") {
				const start = moment(event.start);
				const end = moment(event.end);
				const duration = moment.duration(end.diff(start)).asHours();
				totalDuration += duration;
			}
		});

		totalWorkingTime.value = totalDuration.toFixed(2); // Display the total in hours
	}
};

// Detect screen size and switch views
const updateViewOnResize = () => {
	const calendarApi = calendarRef.value?.getApi();
	if (calendarApi) {
		const width = window.innerWidth;
		if (width < 768) {
			calendarApi.changeView("timeGridDay");
			isMobile.value = true;
			
		} else {
			calendarApi.changeView("timeGridWeek");
			isMobile.value = false;
		}
	}
};

// Attach and detach event listeners
onMounted(async() => {
	try {
		const userResponse = await userService.get(props.userId);
		currentUser.value = userResponse;

		if (currentUser.value) {
			clockManager = new clockManagerService(currentUser.value);
		}
		
		updateViewOnResize(); // Set the initial view based on screen size
		window.addEventListener("resize", updateViewOnResize); // Listen for screen size changes
	} catch (error) {
		console.error("Failed to fetch user:", error);
	}

});

onBeforeUnmount(() => {
	window.removeEventListener("resize", updateViewOnResize); // Cleanup
});

// State to hold the calendar options
const calendarOptions = ref({
  plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin],
  initialView: "timeGridWeek",
  height: "auto",
  // Determine initial values for desktop or mobile
  selectable: canEdit && !isMobile.value, 
  selectMirror: canEdit && !isMobile.value, 
  editable: canEdit && !isMobile.value, 
  events: [] as calendarEvent[],
  allDaySlot: false,
  select: handleSelect,
  eventDrop: handleEventDrop,
  eventResize: handleEventResize,
  eventClick: handleEventClick,
  
  // When the view is mounted or updated
  viewDidMount: (info: any) => {
    if (info.view.type === "dayGridMonth" || info.view.type === "dayGridDay") {
      // Disable editing in Month view and day view
      calendarOptions.value.selectable = false;
      calendarOptions.value.editable = false;
    } else if (info.view.type === "timeGridWeek" ) {
      // Enable editing in Week and Day views only on desktop and when canEdit is true
      calendarOptions.value.selectable = canEdit && !isMobile.value;
      calendarOptions.value.editable = canEdit && !isMobile.value;
    } else {
      // Disable editing in other views (like mobile)
      calendarOptions.value.selectable = false;
      calendarOptions.value.editable = false;
    }
  },
  
  // Trigger when view changes
  datesSet: (info: any) => {
    if (info.view.type === "dayGridMonth" || info.view.type === "dayGridDay") {
      // Disable editing in Month view and day view
      calendarOptions.value.selectable = false;
      calendarOptions.value.editable = false;
    } else if (info.view.type === "timeGridWeek" ) {
      // Enable editing in Week and Day views only on desktop and when canEdit is true
      calendarOptions.value.selectable = canEdit && !isMobile.value;
      calendarOptions.value.editable = canEdit && !isMobile.value;
    } else {
      // Disable editing in other views (like mobile)
      calendarOptions.value.selectable = false;
      calendarOptions.value.editable = false;
    }
    refreshCalendar();
  },

  // Calendar header configuration
  headerToolbar: {
    left: 'prev next today',
    center: 'title',
    right: 'dayGridMonth timeGridWeek timeGridDay'
  },
  
  buttonText: {
    today: 'Today',
    month: 'Month',
    week: 'Week',
    day: 'Day'
  },
});
</script>

<style>
.fc {
  font-family: 'Arial', sans-serif !important;
}

.fc .fc-toolbar {
	  padding: 10px !important;
	  border-radius: 1rem !important;
  background-color: #f4f4f9 !important;
  border-bottom: 2px solid #ccc !important;
}

.fc .fc-daygrid-day-number {
  font-weight: bold !important;
  color: #333 !important;
}

.fc .fc-daygrid-day {
  background-color: #f9fafb !important;
}

.fc .fc-event {
  border: none !important;
  color: black !important;
  padding: 5px !important;
  border-radius: 4px !important;
}

.fc .fc-day-today {
  background-color: #fff5a0 !important;
}

.fc .fc-button-primary {
  background-color: #3f51b5 !important;
  border-color: #3f51b5 !important;
}

.fc .fc-button-primary:hover {
  background-color: #283593 !important;
  border-color: #283593 !important;
}

.fc .fc-timegrid-slot-label {
  background-color: #f0f0f0 !important;
}

.fc .fc-timegrid-event {
  color: white !important;
  border-radius: 4px !important;
  padding: 2px 5px !important;
}

.fc-header-toolbar {
  display: flex !important;
  justify-content: space-between !important;
  align-items: center !important;
}

/* Adjust toolbar for mobile screens */
@media (max-width: 768px) {
  .fc-header-toolbar {
    flex-direction: column !important; /* Stack the toolbar items */
    align-items: flex-start !important;
  }

  .fc-header-toolbar .fc-toolbar-chunk {
    margin-bottom: 10px !important; /* Add spacing between chunks */
    width: 100% !important; /* Make buttons take full width */
    text-align: center !important;
  }

  .fc-toolbar-title {
    font-size: 1rem !important; 
  }

  .fc-button {
    padding: 5px 10px !important; /* Adjust button padding for mobile */
    font-size: 14px !important;
  }
}
</style>
