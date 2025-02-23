<template>
  <div class="p-6 bg-third">
    <!-- General Manager Section -->
    <h1 class="text-2xl font-bold mb-4">
      General Manager <span class="text-gray-600">({{ totalTeams }} Teams)</span>
    </h1>

    <div class="bg-white border border-gray-300 rounded-lg shadow-md p-4 mb-6">
      <div class="flex justify-between items-center">
        <!-- General Manager Info -->
        <div>
          <h2 class="text-xl font-semibold">General Manager: {{ generalManager.username }}</h2>
          <p class="text-gray-600">Role: {{ generalManager.role }}</p>
        </div>
        <div class="flex items-center space-x-2 mb-4">

          <!-- Search input for teams -->
          <input v-model="searchTeamQuery" placeholder="Search teams..." class="border rounded px-4 py-2 w-full"
            type="text" />
          <button @click="openNewTeamModal()"
            class="ml-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 text-lg">
            Add
          </button>
        </div>

      </div>
    </div>
    <!-- New Team Modal -->
    <div v-if="isNewTeamModalVisible"
      class="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50">
      <div class="bg-white rounded-lg shadow-lg w-full max-w-md p-6 transform transition-all duration-300">
        <h2 class="text-2xl font-bold mb-6 text-center">Create New Team</h2>

        <!-- Form -->
        <form @submit.prevent="createTeam">
          <!-- Team Name Field -->
          <div class="mb-6">
            <label for="team-name" class="block text-gray-700 font-semibold mb-2">Team Name:</label>
            <input v-model="newTeam.name" id="team-name"
              class="border border-gray-300 rounded-lg px-4 py-3 w-full focus:ring-2 focus:ring-blue-400 focus:outline-none transition duration-200"
              type="text" placeholder="Enter team name" required />
          </div>

          <div class="flex justify-end space-x-4">
            <button type="button" @click="closeNewTeamModal"
              class="px-6 py-3 bg-gray-300 text-gray-700 rounded-lg shadow-md hover:bg-gray-400 focus:outline-none focus:ring-4 focus:ring-gray-400 focus:ring-opacity-50 transition duration-300 ease-in-out transform hover:-translate-y-1">
              Cancel
            </button>

            <button type="submit"
              class="px-6 py-3 bg-blue-600 text-white rounded-lg shadow-md hover:bg-blue-700 focus:outline-none focus:ring-4 focus:ring-blue-400 focus:ring-opacity-50 transition duration-300 ease-in-out transform hover:-translate-y-1">
              Create
            </button>
          </div>
        </form>
      </div>
    </div>


    <!-- Manage Teams Section -->
    <h2 class="text-xl font-semibold mb-2">Manage Teams</h2>
    <DataTable v-model:selection="selectedTeams" :value="filteredTeams" dataKey="id" :paginator="true" :rows="5"
      :rowsPerPageOptions="[5, 10, 20]" class="bg-white border border-gray-300 rounded-lg shadow-md mb-6">
      <Column selectionMode="multiple" style="width: 3em"></Column>
      <Column header="Team Name" field="name" style="width: 25%"></Column>
      <Column header="Last Update" field="updated_at" style="width: 25%"></Column>
      <Column header="Members Count" field="user_count" style="width: 20%"></Column>
      <Column header="Actions" style="width: 10em">
        <template #body="{ data }">
          <div class="flex space-x-2">

            <button @click="openAddMembersModal(data)" class="p-button p-button-text p-button-rounded">
              <i class="pi pi-plus text-blue-600"></i>
            </button>
            <button @click="editTeam(data)" class="text-blue-600 hover:underline">
              <i class="pi pi-pencil" aria-hidden="true"></i>
            </button>
            <button @click="confirmDeleteTeam(data)" class="text-red-600 hover:underline">
              <i class="pi pi-trash" aria-hidden="true"></i>
            </button>
          </div>
        </template>
      </Column>
    </DataTable>
    <!-- Add Members Modal -->
    <div v-if="isAddMembersModalVisible"
      class="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50">
      <div class="bg-white p-8 rounded-lg shadow-xl w-full max-w-2xl transform transition-all duration-300">
        <h2 class="text-2xl font-bold text-center mb-6">Manage Members for Team: {{ selectedTeam ? selectedTeam.name :
          '' }}
        </h2>

        <!-- Current Team Members Section -->
        <div class="mb-6">
          <h3 class="text-lg font-semibold mb-3">Current Members:</h3>
          <ul class="space-y-3">
            <li v-for="member in teamMembers" :key="member.id"
              class="flex justify-between items-center bg-gray-100 px-4 py-2 rounded-lg">
              <span class="text-gray-700">{{ member.username }}</span>
              <button @click="removeUserFromTeam(selectedTeam.id, member.id)"
                class="text-red-600 hover:text-red-700 transition duration-200">
                Remove
              </button>
            </li>
          </ul>
        </div>

        <!-- Add New Members Section with Dropdown -->
        <div class="mb-6">
          <h3 class="text-lg font-semibold mb-3">Add New Member:</h3>
          <div class="flex items-center">
            <select v-model="selectedUserToAdd"
              class="border border-gray-300 rounded-lg px-4 py-3 w-full focus:ring-2 focus:ring-blue-400 focus:outline-none transition duration-200">
              <option value="" disabled>Select a user to add</option>
              <option v-for="member in availableMembers" :key="member.id" :value="member.id">
                {{ member.username }}
              </option>
            </select>
            <button @click="addUserToTeam(selectedTeam.id, selectedUserToAdd)"
              class="ml-4 bg-green-600 text-white px-6 py-3 rounded-lg shadow-md hover:bg-green-700 focus:outline-none focus:ring-4 focus:ring-green-400 transition duration-300 ease-in-out transform hover:-translate-y-1">
              Add
            </button>
          </div>
        </div>

        <!-- Modal Actions -->
        <div class="flex justify-end space-x-4 mt-6">
          <button @click="closeAddMembersModal"
            class="px-6 py-3 bg-gray-300 text-gray-700 rounded-lg shadow-md hover:bg-gray-400 focus:outline-none focus:ring-4 focus:ring-gray-400 transition duration-300">
            Close
          </button>
        </div>
      </div>
    </div>



    <div class="bg-white border border-gray-300 rounded-lg shadow-md p-4 mb-6">
      <div class="flex justify-between items-center">
        <!-- Manager Info -->
        <!-- New Dynamic Blocks for Each Selected Team -->
        <div v-if="selectedTeams.length > 0" class="bg-white border border-gray-300 rounded-lg shadow-md p-4 mb-6">
          <h2 class="text-xl font-semibold mb-4">Selected Team(s) and Manager(s)</h2>
          <div class="flex flex-wrap justify-start gap-4">
            <div v-for="team in selectedTeams" :key="team.id"
              class="bg-gray-100 border border-gray-200 rounded-lg p-4 shadow-lg"
              style="flex: 0 0 200px; max-width: 300px; min-width: 300px;">
              <p class="text-gray-800 font-semibold text-lg truncate">Team: {{ team.name }}</p>
              <p class="text-gray-600 text-md truncate">Members : {{ team.user_count }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>


    <h2 class="text-xl font-semibold mb-2">
      Team Members <span class="text-gray-600">({{ totalMembers }} users)</span>
    </h2>

    <div class="bg-white border border-gray-300 rounded-lg shadow-md p-4 mb-6">
      <div class="flex items-center mb-4">
        <!-- Search Input for Members -->
        <input type="text" v-model="searchQuery" placeholder="Search members..."
          class="border rounded px-4 py-2 text-base w-full" />

        <!-- Add New Member Button -->
        <button @click="openCreateUserModal"
          class="ml-2 px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 text-lg">
          Add
        </button>
      </div>
    </div>



    <!-- Member Table Section -->
    <DataTable :value="filteredAndHighlightedMembers" dataKey="id" :paginator="true" :rows="5"
      :rowsPerPageOptions="[5, 10, 20]" class="bg-white border border-gray-300 rounded-lg shadow-md"
      @selection-change="onSelectionChange">

      <!-- Name Column -->
      <Column header="Name" style="width: 15%">
        <template #body="{ data }">
          <div :class="{ 'highlight-row': data.isInSelectedTeam }">
            <span class="font-bold">{{ data.username }}</span><br />
            <span class="text-gray-600">{{ data.email }}</span>
          </div>
        </template>
      </Column>

      <!-- Roles Column -->
      <Column header="Roles" style="width: 20%">
        <template #body="{ data }">
          <div>
            <!-- Display user-friendly roles with comma separation -->
            <span v-for="(role, index) in formatRoles(data.roles)" :key="index" class="badge">
              {{ role }}<span v-if="index < formatRoles(data.roles).length - 1">,</span>
            </span>
          </div>
        </template>
      </Column>

      <!-- Progress Column -->
      <Column header="Progress" style="width: 25%">
        <template #body="{ data }">
          <div class="relative pt-1">
            <div class="flex justify-between">
              <div>
                <!-- Displaying hours worked out of total hours -->
                <span class="text-sm text-gray-600">{{ data.totalClockedTime }} / {{ data.totalWorkedTime }}
                  Hours</span>
              </div>
            </div>
            <div class="flex">
              <div class="w-full bg-gray-200 rounded">
                <!-- Progress bar showing percentage of hours worked -->
                <div class="bg-blue-500 h-2 rounded"
                  :style="{ width: ((data.totalClockedTime / data.totalWorkedTime) * 100) + '%' }">
                </div>
              </div>
            </div>
          </div>
        </template>
      </Column>

      <!-- Email Column -->
      <Column field="email" header="Email address"></Column>

      <!-- Contract Column -->
      <Column header="Contract" style="width: 20%">
        <template #body="{ data }">
          <div>
            <!-- Display the contract value (total worked time for the current month) -->
            <span>{{ data.totaltimepermonth }}h/month</span>
          </div>
        </template>
      </Column>

      <!-- Actions Column -->
      <Column header="Actions" style="width: 10em">
        <template #body="{ data }">
          <div class="flex space-x-2">
            <!-- View Member Button -->
            <button @click="viewMember(data)" class="text-green-600 hover:underline">
              <i class="pi pi-eye" aria-hidden="true"></i>
            </button>

            <button @click="viewMemberCalendar(data)" class="text-violet-600 hover:underline">
              <i class="pi pi-calendar" aria-hidden="true"></i>
            </button>

            <!-- Edit Member Button -->
            <button @click="openEditMemberModal(data)" class="text-blue-600 hover:underline">
              <i class="pi pi-pencil" aria-hidden="true"></i>
            </button>

            <!-- Delete Member Button -->
            <button @click="openDeleteUserModal(data)" class="text-red-600 hover:underline">
              <i class="pi pi-trash" aria-hidden="true"></i>
            </button>

            <!-- Promote and Demote Buttons with Dynamic Logic -->
            <!-- Show only up arrow if user has ROLE_USER -->
            <button
              v-if="data.roles.includes('ROLE_USER') && !data.roles.includes('ROLE_MANAGER') && !data.roles.includes('ROLE_SUPERMANAGER')"
              @click="promoteMember(data)" class="text-yellow-600 hover:underline">
              <i class="pi pi-arrow-up" aria-hidden="true" title="Promote to Manager"></i>
            </button>

            <!-- Show both up and down arrows if user has ROLE_MANAGER -->
            <button v-if="data.roles.includes('ROLE_MANAGER') && !data.roles.includes('ROLE_SUPERMANAGER')"
              @click="promoteMember(data)" class="text-yellow-600 hover:underline">
              <i class="pi pi-arrow-up" aria-hidden="true" title="Promote to Supermanager"></i>
            </button>
            <button v-if="data.roles.includes('ROLE_MANAGER') && !data.roles.includes('ROLE_SUPERMANAGER')"
              @click="demoteMember(data)" class="text-orange-600 hover:underline">
              <i class="pi pi-arrow-down" aria-hidden="true" title="Demote to User"></i>
            </button>

            <!-- Show only down arrow if user has ROLE_SUPERMANAGER -->
            <button v-if="data.roles.includes('ROLE_SUPERMANAGER')" @click="demoteMember(data)"
              class="text-orange-600 hover:underline">
              <i class="pi pi-arrow-down" aria-hidden="true" title="Demote to Manager"></i>
            </button>



          </div>
        </template>
      </Column>

    </DataTable>
    <!-- Error Message Popups -->
    <div class="error-container">
      <div v-for="error in errorMessages" :key="error.id" class="popup-error">
        {{ error.text }}
      </div>
    </div>

    <!-- Success Message Popups -->
    <div class="success-container">
      <div v-for="success in successMessages" :key="success.id" class="popup-success">
        {{ success.text }}
      </div>
    </div>






    <!-- New Member Modal -->
    <div v-if="isNewMemberModalVisible"
      class="fixed inset-0 bg-gray-800 bg-opacity-70 flex justify-center items-center z-50">
      <div class="bg-white p-6 rounded-lg shadow-lg w-full max-w-lg">
        <h2 class="text-2xl font-bold text-gray-800 mb-6 text-center">Create New User</h2>

        <!-- Username Field -->
        <div class="mb-4">
          <label class="block text-lg font-medium text-gray-700">Username</label>
          <input v-model="createUsername" type="text"
            class="p-3 mt-2 w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="Enter username" />
        </div>

        <!-- Email Field -->
        <div class="mb-4">
          <label class="block text-lg font-medium text-gray-700">Email</label>
          <input v-model="createEmail" type="email"
            class="p-3 mt-2 w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="Enter email" />
        </div>

        <!-- Password Field -->
        <div class="mb-4">
          <label class="block text-lg font-medium text-gray-700">Password</label>
          <input v-model="createPassword" type="password"
            class="p-3 mt-2 w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            placeholder="Enter password" />
        </div>


        <div
          class="flex flex-col sm:flex-row sm:justify-between sm:items-center mt-6 space-y-4 sm:space-y-0 sm:space-x-4">
          <!-- Create User Button -->
          <button @click="createUser"
            class="px-6 py-3 bg-blue-600 text-white rounded-lg shadow-md hover:bg-blue-700 focus:outline-none focus:ring-4 focus:ring-blue-400 focus:ring-opacity-50 transition duration-300 ease-in-out transform hover:-translate-y-1"
            aria-label="Create User">
            Create User
          </button>

          <button @click="closeCreateUserModal"
            class="px-6 py-3 bg-gray-300 text-gray-700 rounded-lg shadow-md hover:bg-gray-400 focus:outline-none focus:ring-4 focus:ring-gray-400 focus:ring-opacity-50 transition duration-300 ease-in-out transform hover:-translate-y-1"
            aria-label="Cancel">
            Cancel
          </button>
        </div>

      </div>
    </div>





    <!-- Edit Team Modal -->
    <div v-if="isTeamModalVisible" class="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50">
      <div class="bg-white p-8 rounded-lg shadow-xl w-full max-w-md transform transition-all duration-300">
        <h2 class="text-2xl font-bold text-center mb-6">Edit Team: {{ editableTeam.name }}</h2>

        <form @submit.prevent="updateTeam()">
          <!-- Team Name Input -->
          <div class="mb-6">
            <label for="team-name" class="block text-gray-700 font-semibold mb-2">Team Name:</label>
            <input v-model="editableTeam.name" id="team-name"
              class="border border-gray-300 rounded-lg px-4 py-3 w-full focus:ring-2 focus:ring-blue-400 focus:outline-none transition duration-200"
              type="text" placeholder="Enter team name" required />
          </div>

          <!-- Action Buttons -->
          <div class="flex justify-end space-x-4">
            <!-- Cancel Button -->
            <button type="button" @click="closeTeamModal()"
              class="px-6 py-3 bg-gray-300 text-gray-700 rounded-lg shadow-md hover:bg-gray-400 focus:outline-none focus:ring-4 focus:ring-gray-400 transition duration-300">
              Cancel
            </button>

            <!-- Save Changes Button -->
            <button type="submit"
              class="px-6 py-3 bg-blue-600 text-white rounded-lg shadow-md hover:bg-blue-700 focus:outline-none focus:ring-4 focus:ring-blue-400 transition duration-300 ease-in-out transform hover:-translate-y-1">
              Save Changes
            </button>
          </div>
        </form>
      </div>
    </div>


    <!-- Confirmation Delete Modal for Team -->
    <div v-if="isDeleteTeamModalVisible"
      class="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50">
      <div class="bg-white p-8 rounded-lg shadow-xl w-full max-w-md transform transition-all duration-300">
        <h2 class="text-2xl font-bold text-center mb-6 text-red-600">Confirm Deletion</h2>

        <p class="text-gray-700 text-center mb-6">Are you sure you want to delete the team <strong>{{ teamToDelete.name
            }}</strong>? This action cannot be undone.</p>

        <!-- Action Buttons -->
        <div class="flex justify-end space-x-4">
          <!-- Cancel Button -->
          <button type="button" @click="closeDeleteModal()"
            class="px-6 py-3 bg-gray-300 text-gray-700 rounded-lg shadow-md hover:bg-gray-400 focus:outline-none focus:ring-4 focus:ring-gray-400 transition duration-300">
            Cancel
          </button>

          <!-- Delete Button -->
          <button type="button" @click="deleteTeam(teamToDelete.id)"
            class="px-6 py-3 bg-red-600 text-white rounded-lg shadow-md hover:bg-red-700 focus:outline-none focus:ring-4 focus:ring-red-400 transition duration-300 ease-in-out transform hover:-translate-y-1">
            Delete
          </button>
        </div>
      </div>
    </div>


    <!-- Edit Member Modal -->
    <div v-if="isEditMemberModalOpen"
      class="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50">
      <div class="bg-white p-8 rounded-lg shadow-xl w-full max-w-lg transform transition-all duration-300">
        <h2 class="text-2xl font-bold text-center mb-6">Edit Member: {{ editableMember.username }}</h2>

        <form @submit.prevent="updateMember()">
          <!-- Username Field -->
          <div class="mb-6">
            <label for="username" class="block text-gray-700 font-semibold mb-2">Username:</label>
            <input v-model="editableMember.username" id="username"
              class="border border-gray-300 rounded-lg px-4 py-3 w-full focus:ring-2 focus:ring-blue-400 focus:outline-none transition duration-200"
              type="text" required />
          </div>

          <!-- Email Field -->
          <div class="mb-6">
            <label for="email" class="block text-gray-700 font-semibold mb-2">Email:</label>
            <input v-model="editableMember.email" id="email"
              class="border border-gray-300 rounded-lg px-4 py-3 w-full focus:ring-2 focus:ring-blue-400 focus:outline-none transition duration-200"
              type="email" required />
          </div>

          <!-- Password Field (Optional) -->
          <div class="mb-6">
            <label for="password" class="block text-gray-700 font-semibold mb-2">Password (optional):</label>
            <input v-model="editableMember.password" id="password"
              class="border border-gray-300 rounded-lg px-4 py-3 w-full focus:ring-2 focus:ring-blue-400 focus:outline-none transition duration-200"
              type="password" placeholder="Enter new password if changing" />
          </div>

          <!-- Action Buttons -->
          <div class="flex justify-end space-x-4">
            <!-- Cancel Button -->
            <button type="button" @click="closeEditMemberModal()"
              class="px-6 py-3 bg-gray-300 text-gray-700 rounded-lg shadow-md hover:bg-gray-400 focus:outline-none focus:ring-4 focus:ring-gray-400 transition duration-300">
              Cancel
            </button>

            <!-- Save Changes Button -->
            <button type="submit"
              class="px-6 py-3 bg-blue-600 text-white rounded-lg shadow-md hover:bg-blue-700 focus:outline-none focus:ring-4 focus:ring-blue-400 transition duration-300 ease-in-out transform hover:-translate-y-1">
              Save Changes
            </button>
          </div>
        </form>
      </div>
    </div>



    <!-- Confirmation Delete Modal for Member -->
    <div v-if="isDeleteUserModalOpen"
      class="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50">
      <div class="bg-white p-8 rounded-lg shadow-xl w-full max-w-md transform transition-all duration-300">
        <h2 class="text-2xl font-bold text-center mb-6 text-red-600">Confirm Deletion</h2>

        <p class="text-gray-700 text-center mb-6">
          Are you sure you want to delete the member <strong>{{ userToDelete?.username }}</strong>? This action cannot
          be
          undone.
        </p>

        <!-- Action Buttons -->
        <div class="flex justify-end space-x-4">
          <!-- Cancel Button -->
          <button type="button" @click="closeDeleteUserModal"
            class="px-6 py-3 bg-gray-300 text-gray-700 rounded-lg shadow-md hover:bg-gray-400 focus:outline-none focus:ring-4 focus:ring-gray-400 transition duration-300">
            Cancel
          </button>

          <!-- Delete Button -->
          <button type="button" @click="deleteMember"
            class="px-6 py-3 bg-red-600 text-white rounded-lg shadow-md hover:bg-red-700 focus:outline-none focus:ring-4 focus:ring-red-400 transition duration-300 ease-in-out transform hover:-translate-y-1">
            Delete
          </button>
        </div>
      </div>
    </div>


  </div>
</template>
<script>
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import Manager from '@/components/SuperManager.vue';

export default {
  components: {
    Manager,
    DataTable,
    Column,
  },
  setup() {
    return Manager.setup();
  },
  data() {
    const superManager = Manager.data();
    return {
      ...superManager,
    };
  },
  computed: {
    filteredTeams() {
      if (!this.searchTeamQuery) {
        return this.teams;
      }
      const query = this.searchTeamQuery.toLowerCase();
      return this.teams.filter(
        (teams) =>
          teams.name.toLowerCase().includes(query)
      );
    },
    totalTeams() {
      return this.teams.length;
    },
    totalMembers() {
      return this.members.length;
    },
    filteredAndSearchedMembers() {
      let filteredMembers;

      // If there's a search query, further filter members based on the query
      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase();
        filteredMembers = filteredMembers.filter(
          member =>
            member.name.toLowerCase().includes(query) ||
            member.email.toLowerCase().includes(query) ||
            member.role.toLowerCase().includes(query)
        );
      }

      return filteredMembers;
    },
  },
  methods: {
    ...Manager.methods,

    onSelectionChange(selection) {
      this.selectedMembers = selection;
    },
  },
};
</script>


<style scoped>
.modal-backdrop {
  position: fixed;
  inset: 0;
  background-color: rgba(0, 0, 0, 0.5);
  z-index: 1;
}

.modal-content {
  background: white;
  border-radius: 8px;
  padding: 20px;
  max-width: 400px;
  width: 100%;
  margin: auto;
  z-index: 1;

}

.highlight-row {
  background-color: #e6f7ff;
  /* Light blue color for highlighting */
}

.z-50 {
  z-index: 50;
}

.max-w-lg {
  max-width: 32rem;
  /* Adjust max width */
}

.space-y-2>*+* {
  margin-top: 0.5rem;
  /* Spacing between list items */
}

/* Container for error messages, fixed to bottom-right */
.error-container {
  position: fixed;
  bottom: 20px;
  right: 20px;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 10px;
  /* Space between messages */
  z-index: 1000;
}

/* Individual error message style */
.popup-error {
  background-color: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
  border-radius: 5px;
  padding: 10px 20px;
  opacity: 0;
  animation: fadeInOut 5s forwards;
}



/* Container for success messages, fixed to bottom-right */
.success-container {
    position: fixed;
    bottom: 80px; /* Offset to appear above error messages */
    right: 20px;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 10px; /* Space between messages */
    z-index: 1000;
}

/* Individual success message style */
.popup-success {
    background-color: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
    border-radius: 5px;
    padding: 10px 20px;
    opacity: 0;
    animation: fadeInOut 5s forwards;
}

/* Keyframes for fade in and fade out */
@keyframes fadeInOut {
  0% {
    opacity: 0;
    transform: translateY(10px);
  }

  10%,
  90% {
    opacity: 1;
    transform: translateY(0);
  }

  100% {
    opacity: 0;
    transform: translateY(-10px);
  }
}


</style>