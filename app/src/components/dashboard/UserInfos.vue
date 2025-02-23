<script setup lang="ts">
import { ref } from "vue";
import type { User } from "@/types/user";
import moment from "moment";
import Button from "primevue/button";
import UserService from "@/services/userService";
import { useAuthStore } from "@/stores/auth";
import { useRouter } from "vue-router";

const { user } = defineProps<{ user: User }>();
const authStore = useAuthStore();
const router = useRouter();

const showPopup = ref(false);
const showDeleteConfirmation = ref(false); // New property for delete confirmation
const username = ref('');
const email = ref('');
const password = ref('');
const userId = ref<number | null>(null);
const message = ref("");
const loading = ref(false);
const messageType = ref<"success" | "error" | null>(null); // Track the type of message

// Function to redirect and open the popup
function redirectToEditUser() {
	showPopup.value = true; // Show the popup
	userId.value = user.id; // Set the user ID for updates
	username.value = user.username; // Pre-fill username
	email.value = user.email; // Pre-fill email
	password.value = ""; // Clear password field
	message.value = ""; // Clear any previous messages
	messageType.value = null; // Reset message type
}

async function updateUser() {
	if (userId.value !== null) {
		// Check if the entered values are the same as the current user data
		if (
			username.value === user.username &&
			email.value === user.email &&
			password.value === ""
		) {
			message.value = "No changes detected.";
			messageType.value = null; // No specific message type
			return;
		}

		const userService = new UserService();
		loading.value = true;
		message.value = "";

		if (!username.value || !email.value) {
			message.value = "All fields are required.";
			messageType.value = "error"; // Set message type to error
			loading.value = false;
			return;
		}

		try {
			await userService.update(
				userId.value,
				username.value,
				email.value,
				password.value,
			);
			message.value = "User updated successfully!";
			messageType.value = "success"; // Set message type to success

			// Close the popup after a successful update
			closePopup();

			// Reload the page to update information
			window.location.reload(); // This will refresh the page to reflect the updated information
		} catch (error) {
			const err = error as { response?: { data?: { error: string } } };
			message.value =
				err.response?.data?.error ||
				"Error updating user: Unknown error occurred.";
			messageType.value = "error"; // Set message type to error
		} finally {
			loading.value = false;
		}
	} else {
		message.value = "User ID is required.";
		messageType.value = "error"; // Set message type to error
	}
}

function confirmDeleteUser() {
  showDeleteConfirmation.value = true; // Show confirmation popup
}

async function deleteUserConfirmed() {
  if (userId.value !== null) {
    const userService = new UserService();
    loading.value = true;
    message.value = '';

    try {
      await userService.delete(userId.value); // Call the delete function from UserService
      message.value = 'Account deleted successfully!';
      messageType.value = 'success'; // Set message type to success
      
      // Close the confirmation popup after successful deletion
      showDeleteConfirmation.value = false; // Close the confirmation popup
      closePopup(); // Close the main popup as well

      // Reload the page to reflect the changes
	  authStore.user = null
	  authStore.token = ""
      router.push({ name: "signIn" })
    } catch (error) {
      const err = error as { response?: { data?: { error: string } } };
      message.value = err.response?.data?.error || 'Error deleting account: Unknown error occurred.';
      messageType.value = 'error'; // Set message type to error
    } finally {
      loading.value = false;
    }
  }
}

function closePopup() {
	showPopup.value = false; // Hide the popup
	message.value = ""; // Clear any messages when closing
	messageType.value = null; // Reset message type
}

function closeDeleteConfirmation() {
  showDeleteConfirmation.value = false; // Hide confirmation popup
}

</script>

<template>
  <div id="userInfos">
    <p id="userInfosTitle" class="font-medium text-primary mb-2">My Informations</p>

    <div id="userInfosContainer" v-if="user" class="bg-primary text-secondary flex flex-col justify-around gap-y-4 p-6">
      <Button icon="pi pi-pen-to-square" aria-label="Edit User Informations" id="userInfosEditBtn" @click="redirectToEditUser" />
      <div id="usernameContainer" class="flex flex-col">
        <p id="usernameLabel" class="userInfosLabel">Username</p>
        <p id="usernameValue" class="userInfosValue">{{ user.username }}</p>
      </div>

      <div id="emailContainer" class="flex flex-col">
        <p id="emailLabel" class="userInfosLabel">Email</p>
        <p id="emailValue" class="userInfosValue">{{ user.email }}</p>
      </div>

      <div id="lastLoginContainer" class="flex flex-col">
        <p id="lastLoginLabel" class="userInfosLabel">Last login</p>
        <p id="lastLoginValue" class="userInfosValue">{{ user.last_login ? moment(user.last_login).utc().format("DD/MM/YYYY HH:mm") : "/" }}</p>
      </div>
    </div>

    <!-- Popup for editing user details -->
    <div v-if="showPopup" id="editUserPopup" class="popup-overlay" @click="closePopup">
      <div class="popup-content" @click.stop>
        <Button id="closeEditUserPopup" icon="pi pi-times" @click="closePopup" class="p-button-secondary close-btn" aria-label="Close Popup" />
        <h3 id="editUserPopupTitle">Edit User Informations</h3>
        <div class="flex flex-col">
          <label id="editUsernameLabel" for="editUsernameInput">Username</label>
          <input v-model="username" id="editUsernameInput" type="text" />
        </div>
        <div class="flex flex-col">
          <label id="editEmailLabel" for="editEmailInput">Email</label>
          <input v-model="email" id="editEmailInput" type="email" />
        </div>
        <div class="flex flex-col">
          <label id="editPwdLabel" for="editPwdInput">Password</label>
          <input v-model="password" id="editPwdInput" type="password" />
        </div>
        <p :class="{'text-green-500': messageType === 'success', 'text-red-500': messageType === 'error'}">{{ message }}</p>
        <div class="flex justify-between mt-4">
          <Button id="updateUserBtn" label="Update" @click="updateUser" :loading="loading" />
          <Button id="deleteUserBtn" label="Delete" @click="confirmDeleteUser" class="p-button-danger" /> <!-- Trigger confirmation popup -->
        </div>
      </div>
    </div>

    <!-- Confirmation Popup for Deleting User Account -->
    <div id="deleteUserPopup" v-if="showDeleteConfirmation" class="popup-overlay" @click="closeDeleteConfirmation">
      <div class="popup-content" @click.stop style="width: 400px;"> <!-- Increased width for confirmation popup -->
        <Button id="closeDeleteUserPopup" icon="pi pi-times" @click="closeDeleteConfirmation" class="p-button-secondary close-btn" aria-label="Close Confirmation Popup" />
        <h3 id="deleteUserTitle">Confirm Account Deletion</h3>
        <p id="deleteUserContent">Are you sure you want to delete your account? This action cannot be undone.</p>
        <div class="flex justify-between mt-4">
          <Button id="deleteUserCancelBtn" label="Cancel" @click="closeDeleteConfirmation" class="p-button-text" />
          <Button id="deleteUserConfirmBtn" label="Delete" @click="deleteUserConfirmed" class="p-button-danger" :loading="loading" />
        </div>
      </div>
    </div>
  </div>

</template>

<style scoped>
#userInfosContainer {
	height: 32vh;
	border-radius: 20px;
	position: relative;
}

#userInfosEditBtn {
	position: absolute;
	top: 20px;
	right: 20px;
}

.userInfosValue {
	@apply font-bold text-base;
}

#userInfosTitle {
	font-size: 1.5rem;
}

/* Styles for the popup */
.popup-overlay {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background: rgba(0, 0, 0, 0.5);
	display: flex;
	align-items: center;
	justify-content: center;
	z-index: 1;
}

.popup-content {
  position: relative; /* Ensure relative positioning for absolute elements */
  background: white;
  padding: 20px;
  border-radius: 8px;
  width: 300px; /* Default width */
}

.close-btn {
	position: absolute;
	top: 10px;
	right: 10px;
	display: flex;
	align-items: center;
	justify-content: center;
	border-radius: 10%;
	background-color: #124e78;
	border: none;
	cursor: pointer;
	transition: background-color 0.3s;
}

.close-btn:hover {
	background-color: #d0d0d0; /* Darken background on hover */
}

.popup-content h3 {
	margin-bottom: 20px;
}

.popup-content input {
	margin-bottom: 10px;
	padding: 10px;
	border: 1px solid #ccc;
	border-radius: 4px;
}

.text-green-500 {
  color: green; /* Success message color */
}

.text-red-500 {
  color: red; /* Error message color */
}
</style>
