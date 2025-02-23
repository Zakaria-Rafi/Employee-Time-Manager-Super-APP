<template>
  <div class="p-6 bg-third">
    <h1 class="text-2xl font-bold mb-4">
      Team members <span class="text-gray-600"></span>
    </h1>

    <div class="bg-white border border-gray-300 rounded-lg shadow-md p-4 mb-6">
      <div class="flex justify-between items-center">
        <!-- Manager Info -->
        <div>
          <h2 class="text-xl font-semibold">Manager: {{ Getmanager.username }}</h2>
          <p class="text-gray-600">Role: {{ Getmanager.role }}</p>
        </div>
      </div>
    </div>

    <DataTable v-model:expandedRows="expandedRows" :value="detailedTeamMembers" dataKey="id"
      class="bg-white border border-gray-300 rounded-lg shadow-md">
      <!-- Column with expand/collapse icon -->
      <Column expander style="width: 3em"></Column>

      <!-- Team Name Column -->
      <Column field="name" header="Team Name"></Column>

      <!-- Manager Info Column -->
      <Column header="Manager">
        <template #body="{ data }">
          <span>{{ data.users[0]?.username || 'Unknown' }}</span> <!-- Display first user as manager -->
        </template>
      </Column>

      <!-- Expanded Row Content: Display list of team members -->
      <template #expansion="slotProps">
        <div class="p-4 bg-gray-50 rounded-lg shadow-lg">
          <h5 class="text-xl font-bold mb-4">Members of {{ slotProps.data.name }}</h5>

          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <!-- Display each user as a card -->
            <div v-for="user in slotProps.data.users" :key="user.id"
              class="bg-white p-4 rounded-lg shadow-md flex flex-col justify-between">
              <!-- User Info -->
              <div>
                <h6 class="text-lg font-semibold mb-2">{{ user.username }}</h6>
                <p class="text-gray-600">{{ user.role || 'No role specified' }}</p>
                <p class="text-gray-600">{{ user.email }}</p>
              </div>

              <!-- Action Buttons -->
              <div class="mt-4 flex justify-end space-x-2">
                <Button icon="pi pi-calendar" class="p-button-rounded p-button-outlined p-button-success"
                  @click="openUserCalendar(user)" />
                <Button icon="pi pi-eye" class="p-button-rounded p-button-outlined p-button-info"
                  @click="openUserDash(user)" />
                <Button icon="pi pi-pencil" class="p-button-rounded p-button-outlined p-button-warning"
                  @click="openeditMember(user)" />
              </div>
            </div>
          </div>
        </div>
      </template>
    </DataTable>


<!-- Edit Member Modal -->
<div v-if="isModalVisible" class="fixed inset-0 bg-gray-900 bg-opacity-50 flex justify-center items-center">
  <div class="bg-white p-8 rounded-lg shadow-lg w-full max-w-md">
    <!-- Modal Header -->
    <h2 class="text-2xl font-semibold mb-6 text-gray-800">Edit Member</h2>
    
    <!-- Edit Form -->
    <form @submit.prevent="updateMember">
      <!-- Username Field -->
      <div class="mb-5">
        <label class="block text-sm font-medium text-gray-600 mb-2">Username</label>
        <input v-model="editableMember.username" 
               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
               type="text" 
               placeholder="Enter username" 
               required />
      </div>
      
      <!-- Email Field -->
      <div class="mb-5">
        <label class="block text-sm font-medium text-gray-600 mb-2">Email</label>
        <input v-model="editableMember.email" 
               class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
               type="email" 
               placeholder="Enter email" 
               required />
      </div>

      <!-- Action Buttons -->
      <div class="flex justify-end space-x-4">
        <button type="button" 
                @click="closeModal" 
                class="px-4 py-2 bg-gray-300 hover:bg-gray-400 text-gray-800 rounded-lg transition ease-in-out duration-200">
          Cancel
        </button>
        <button type="submit" 
                class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition ease-in-out duration-200">
          Save Changes
        </button>
      </div>
    </form>
  </div>
</div>


  </div>
</template>

<script>
import Manager from '@/components/Manager.vue';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import Button from 'primevue/button';

export default {
  components: {
    Manager,
    DataTable,
    Column,
    Button,
  },
  setup() {
    return Manager.setup();
  },
  computed: {
    ...Manager.computed,
  },

  methods: {
    ...Manager.methods,
  }
};
</script>

<style scoped>
</style>
