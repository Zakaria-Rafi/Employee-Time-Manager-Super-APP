<script>
import { ref, onMounted, watch, computed } from 'vue';
import TeamService from '@/services/TeamService';
import UserService from '@/services/userService';
import WorkingTimeService from '@/services/WorkingTimeService';
import { useAuthStore } from '@/stores/auth';
import { useRouter } from 'vue-router';

export default {
  setup() {
    const teams = ref([]);
    const loading = ref(false);
    const error = ref(null);
    const teamService = new TeamService();
    const userService = new UserService();
    const workingTimeService = new WorkingTimeService();
    const editableTeam = ref({});
    const isTeamModalVisible = ref(false);
    const teamToDelete = ref(null);
    const isDeleteTeamModalVisible = ref(false);
    const newTeam = ref({ name: '' });
    const isNewTeamModalVisible = ref(false);
    const selectedTeams = ref([]);
    const selectedTeam = ref(null);
    const members = ref([]);
    const teamMembers = ref([])
    const selectedUserToAdd = ref("");
    const availableMembers = ref([]);
    const isAddMembersModalVisible = ref(false);
    const isNewMemberModalVisible = ref(false);
    const createUsername = ref('');
    const createEmail = ref('');
    const createPassword = ref('');
    const userToDelete = ref(null);
    const isDeleteUserModalOpen = ref(false);
    const editableMember = ref({});
    const isEditMemberModalOpen = ref(false);
    const searchQuery = ref('');
    const clocksData = ref({});
    const authStore = useAuthStore();

    const errorMessages = ref([]);
    const successMessages = ref([]);

    const router = useRouter();

    const loadTeams = async () => {
      loading.value = true;
      error.value = null;
      try {
        const response = await teamService.getAll();
        teams.value = response;
      } catch (err) {
        error.value = 'Failed to load teams. Please try again later.';
      } finally {
        loading.value = false;
      }
    };


    const editTeam = (team) => {
      editableTeam.value = { ...team }; // Clone the team for editing
      isTeamModalVisible.value = true; // Show the modal
    };

    // Function to update a team's information
    const updateTeam = async () => {
      try {
        const updatedTeamData = { name: editableTeam.value.name };
        await teamService.update(editableTeam.value.id, updatedTeamData);
        showSuccess("Team updated successfully.");
        loadTeams();

        isTeamModalVisible.value = false;
      } catch (err) {
        error.value = 'Failed to update the team. Please try again.';
      }
    };
    const closeTeamModal = async () => {
      isTeamModalVisible.value = false;
    };

    const confirmDeleteTeam = (team) => {
      teamToDelete.value = team;
      isDeleteTeamModalVisible.value = true;
    };

    const closeDeleteModal = async () => {
      isDeleteTeamModalVisible.value = false;

    };

    const deleteTeam = async () => {
      if (!teamToDelete.value) return;
      try {
        await teamService.delete(teamToDelete.value.id);
        showSuccess("Team deleted successfully.");
        loadTeams();
        isDeleteTeamModalVisible.value = false;
        teamToDelete.value = null;
      } catch (err) {
        error.value = 'Failed to delete the team. Please try again later.';
      }
    };

    const createTeam = async () => {
      try {
        // Just pass the team name string directly to the service
        const response = await teamService.create(newTeam.value.name);
        showSuccess("Team created successfully.");
        loadTeams();
        closeNewTeamModal(); // Close the modal after successful team creation
      } catch (error) {
        console.error('Error creating team:', error);
      }
    };


    const closeNewTeamModal = () => {
      isNewTeamModalVisible.value = false;
      newTeam.value.name = '';
    };
    const openNewTeamModal = () => {
      isNewTeamModalVisible.value = true;
    };



    const loadMembers = async () => {
      loading.value = true;
      error.value = null;
      try {
        const response = await userService.getAll();
        members.value = response;
      } catch (err) {
        error.value = 'Failed to load members. Please try again later.';
      } finally {
        loading.value = false;
      }

    };


    const addUserToTeam = async (teamId, userId) => {
      if (!userId) return;
      try {
        await teamService.addUser(teamId, userId);
        await fetchTeamMembers(teamId);
        showSuccess("User added to team successfully.");
        selectedUserToAdd.value = "";
      } catch (error) {
        console.error("Failed to add user to team:", error);
      }
    };

    // Remove user from the team
    const removeUserFromTeam = async (teamId, userId) => {
      try {
        await teamService.removeUser(teamId, userId);
        await fetchTeamMembers(teamId);
        showSuccess("User removed from team successfully.");
      } catch (error) {
        console.error("Failed to remove user from team:", error);
      }
    };

    const fetchTeamMembers = async (teamId) => {
      try {
        const teamDetails = await teamService.getById(teamId);
        teamMembers.value = teamDetails.users;
        updateAvailableMembers();
      } catch (error) {
        console.error("Failed to fetch team members:", error);
      }
    };

    watch(selectedTeams, async (newSelection) => {
      if (newSelection.length > 0) {
        selectedTeam.value = newSelection[0];
        await fetchTeamMembers(selectedTeam.value.id);
      } else {
        selectedTeam.value = null;
        teamMembers.value = [];
      }
    });
    // Computed property to filter and highlight members
    const filteredAndHighlightedMembers = computed(() => {
      // Filter members based on the search query
      const filteredMembers = members.value.filter((member) =>
        member.username.toLowerCase().includes(searchQuery.value.toLowerCase())
      );

      // Map over team members and mark them as part of the selected team
      const selectedTeamUsers = teamMembers.value.map((member) => {
        const clockData = clocksData.value[member.id] || {}; // Get clock data for the member, if available
        return {
          ...member,
          isInSelectedTeam: true,
          totalClockedTime: clockData.total_clocked_time || 0, // Add clocked time
          totalWorkedTime: clockData.total_worked_time || 0,   // Add worked time
          totaltimepermonth: calculateTotalWorkedTimeForMonth(clockData.total_worked_time || 0),
        };
      });

      // Filter other users who are not in the team, and mark them as not part of the selected team
      const otherUsers = filteredMembers
        .filter((member) => !teamMembers.value.some((teamMember) => teamMember.username === member.username))
        .map((member) => {
          const clockData = clocksData.value[member.id] || {}; // Get clock data for the member, if available
          return {
            ...member,
            isInSelectedTeam: false,
            totalClockedTime: clockData.total_clocked_time || 0, // Add clocked time
            totalWorkedTime: clockData.total_worked_time || 0,   // Add worked time
            totaltimepermonth: calculateTotalWorkedTimeForMonth(clockData.total_worked_time || 0),

          };
        });

      // Combine the selected team members and other users
      return [...selectedTeamUsers, ...otherUsers];
    });


    const updateAvailableMembers = () => {
      availableMembers.value = members.value.filter(
        (member) => !teamMembers.value.some((teamMember) => teamMember.id === member.id)
      );
    };
    const openAddMembersModal = (team) => {
      selectedTeam.value = team; // Set the selected team
      fetchTeamMembers(team.id); // Fetch team members
      isAddMembersModalVisible.value = true; // Show modal
    };

    // Close Add Members Modal
    const closeAddMembersModal = () => {
      isAddMembersModalVisible.value = false;
      selectedTeam.value = null;
      selectedTeams.value = [];
      loadTeams();
      loadMembers();
    };

    // Function to create a user (triggered from modal)

    const createUser = async () => {
      // Basic validation to check if all fields are filled
      if (!createUsername.value || !createEmail.value || !createPassword.value) {
          showError("All fields are required.");

        return;
      }

      try {
        await userService.create(createUsername.value, createEmail.value, createPassword.value);
        showSuccess("User created successfully.");
        closeCreateUserModal(); // Close modal after successful creation
        clearInputs(); // Clear the input fields
        loadTeams();
        loadMembers();

      } catch (error) {
        const err = error.response?.data?.error || 'Error creating user.';
        showError("Error creating user.");
      }
    };

    // Function to clear the inputs
    const clearInputs = () => {
      createUsername.value = '';
      createEmail.value = '';
      createPassword.value = '';
    };

    // Function to close the modal
    const closeCreateUserModal = () => {
      isNewMemberModalVisible.value = false;
      clearInputs(); // Clear the inputs when closing the modal
      errorMessages.value = '';
    };

    const openCreateUserModal = () => {
      isNewMemberModalVisible.value = true;

    };



    const deleteMember = async () => {
      if (userToDelete.value) {
        const userService = new UserService();
        try {
          // Attempt to delete the user
          await userService.delete(userToDelete.value.id);

          // Set success message and close the modal
          showSuccess("User deleted successfully.");

          // Optionally clear the state or update the UI
          clearInputsdel();
          loadTeams();
          loadMembers();
          // Close the modal after deletion
          isDeleteUserModalOpen.value = false;  // Close the delete modal

        } catch (error) {
          // Handle error during deletion
          const err = error.response?.data?.error || 'Error deleting user.';
          showError("Error deleting user.");
        }
      } else {
        // If no user is selected, show an error message
        showError("No user selected.");
      }
    };

    const openDeleteUserModal = async (user) => {
      userToDelete.value = user;
      isDeleteUserModalOpen.value = true; // Open the modal
    };

    const closeDeleteUserModal = () => {
      isDeleteUserModalOpen.value = false;
    };
    const clearInputsdel = () => {
      userToDelete.value = null;
      errorMessages.value = '';
      successMessages.value = '';
    };


    const openEditMemberModal = (member) => {
      editableMember.value = { ...member };
      isEditMemberModalOpen.value = true;
    };

    const updateMember = async () => {
      if (!editableMember.value.username || !editableMember.value.email) {
        showError("Username and email are required.");
        return;
      }

      try {
        await userService.update(editableMember.value.id, editableMember.value.username, editableMember.value.email, editableMember.value.password || '',
        );
        loadMembers();
        showSuccess("User updated successfully.");
        closeEditMemberModal();
      } catch (error) {
        const err = error.response?.data?.error || 'Error updating user.';
        showError("Error updating user.");
      }
    };

    const closeEditMemberModal = () => {
      editableMember.value = {};
      isEditMemberModalOpen.value = false;
    };
    const loadClocksForAllMembers = async () => {
      try {
        if (members.value.length === 0) {
          console.warn("No members to load clocks for.");
          return;
        }

        const clockPromises = members.value.map(async (member) => {
          try {
            // Try to fetch clocks
            const clocksResponse = await workingTimeService.getClocks(member.id);

            // Check if clocksResponse is valid and has expected properties
            if (!clocksResponse || !Array.isArray(clocksResponse) || clocksResponse.length === 0) {
              // Gracefully handle if clocksResponse is undefined or empty
              return {
                userId: member.id,
                clocks: {
                  total_clocked_time: 0,
                  total_worked_time: 0,
                  noWorkingTime: true,
                },
              };
            }

            // Get the first item's total clocked and worked time
            let totalClockedTime = clocksResponse[0]?.total_clocked_time || 0;
            let totalWorkedTime = clocksResponse[0]?.total_worked_time || 0;

            // Convert time from seconds to hours
            totalClockedTime = Math.round(totalClockedTime / 60 / 60);
            totalWorkedTime = Math.round(totalWorkedTime / 60 / 60);

            return {
              userId: member.id,
              clocks: {
                total_clocked_time: totalClockedTime,
                total_worked_time: totalWorkedTime,
              },
            };
          } catch (error) {
            // Suppress TypeError if it's related to undefined properties
            if (error instanceof TypeError) {
              // You can decide to handle this error silently by not logging anything
              return {
                userId: member.id,
                clocks: {
                  total_clocked_time: null,
                  total_worked_time: null,
                  error: true,
                },
              };
            }

            // Handle other errors like 404 or other server-related errors
            if (error.response?.status === 404 && error.response?.data?.error === "working_time.clock_not_found") {
              return {
                userId: member.id,
                clocks: {
                  total_clocked_time: null,
                  total_worked_time: null,
                  noWorkingTime: true,
                },
              };
            } else {
              // Handle other types of errors
              return {
                userId: member.id,
                clocks: {
                  total_clocked_time: null,
                  total_worked_time: null,
                  error: true,
                },
              };
            }
          }
        });

        const results = await Promise.all(clockPromises);

        results.forEach(({ userId, clocks }) => {
          clocksData.value[userId] = clocks;
        });

      } catch (error) {
        if (!(error instanceof TypeError)) {
          console.error("Error fetching clocks for all members:", error);
        }
      }
    };

    const calculateTotalWorkedTimeForMonth = (hoursPerDay) => {
      const today = new Date();

      // Get the first and last day of the current month
      const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
      const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0);

      // Initialize working days counter
      let workdays = 0;

      // Loop through each day of the current month
      for (let day = firstDay; day <= lastDay; day.setDate(day.getDate() + 1)) {
        const dayOfWeek = day.getDay();

        // Check if it's a weekday (Monday to Friday)
        if (dayOfWeek !== 0 && dayOfWeek !== 6) { // 0 = Sunday, 6 = Saturday
          workdays++;
        }
      }

      const totalWorkedTimeForMonth = workdays * hoursPerDay;
      return totalWorkedTimeForMonth; // Return the total worked time in hours
    };


    watch(members, (newValue) => {
      if (newValue.length > 0) {
        loadClocksForAllMembers();
      }
    });

    const generalManager = computed(() => {
      return {
        username: authStore.user.username,
        role: "General Manager",
      };
    });

    const viewMember = (member) => {
      router.push({ name: 'dashboard', params: { userId: member.id } });
    };

    const viewMemberCalendar = (member) => {
      router.push({ name: 'workingTimes', params: { userId: member.id } });
    };



    const promoteMember = async (member) => {
      // Promote user to manager if they only have ROLE_USER
      if (member.roles.includes('ROLE_USER') && !member.roles.includes('ROLE_MANAGER') && !member.roles.includes('ROLE_SUPERMANAGER')) {
        const updatedMember = await userService.promote(member.id, 'ROLE_MANAGER'); // Adds ROLE_MANAGER
        showSuccess("User successfully promoted to Manager.");
        loadMembers();
      }
      // Promote manager to supermanager
      else if (member.roles.includes('ROLE_MANAGER') && !member.roles.includes('ROLE_SUPERMANAGER')) {
        const updatedMember = await userService.promote(member.id, 'ROLE_SUPERMANAGER'); // Adds ROLE_SUPERMANAGER
        showSuccess("User successfully promoted to Supermanager.");
        loadMembers();
      } else {
        showError(`${member.username} is already at the highest role.`);
      }
    };

    const demoteMember = async (member) => {

      if (member.id === authStore.user.id) {
        showError("Error: You cannot demote yourself as a Supermanager.");

        return;
      }
      if (member.roles.includes('ROLE_SUPERMANAGER')) {
        const updatedMember = await userService.demote(member.id, 'ROLE_SUPERMANAGER');
        showSuccess("User successfully demoted to Manager.");

        loadMembers();
      }
      // Demote manager to user
      else if (member.roles.includes('ROLE_MANAGER')) {
        const updatedMember = await userService.demote(member.id, 'ROLE_MANAGER');
        showSuccess("User successfully demoted to User.");
        loadMembers();
      } else {
        showError(`${member.username} is already at the lowest role.`);
      }
    };


    const roleMapping = {
      'ROLE_USER': 'user',
      'ROLE_MANAGER': 'manager',
      'ROLE_SUPERMANAGER': 'supermanager'
    };

    const formatRoles = (roles) => {
      return roles
        .filter(role => roleMapping[role])
        .map(role => roleMapping[role]);
    };

    const showError = (text) => {
      const id = Date.now();
      errorMessages.value.push({ id, text, type: 'error' });

      setTimeout(() => {
        errorMessages.value = errorMessages.value.filter(error => error.id !== id);
      }, 2000);
    };
    const showSuccess = (text) => {
      const id = Date.now();
      successMessages.value.push({ id, text, type: 'success' });

      setTimeout(() => {
        successMessages.value = successMessages.value.filter(success => success.id !== id);
      }, 2000);
    };



    onMounted(() => {
      loadTeams();
      loadMembers();
    });

    return {
      generalManager,
      availableMembers,
      teamMembers,
      teams,
      loading,
      error,
      editableTeam,
      isTeamModalVisible,
      editTeam,
      updateTeam,
      isDeleteTeamModalVisible,
      confirmDeleteTeam,
      deleteTeam,
      teamToDelete,
      closeDeleteModal,
      createTeam,
      closeNewTeamModal,
      closeTeamModal,
      isNewTeamModalVisible,
      newTeam,
      selectedTeams,
      filteredAndHighlightedMembers,
      searchQuery,
      selectedTeam,
      loadMembers,
      members,
      openNewTeamModal,
      addUserToTeam,
      removeUserFromTeam,
      openAddMembersModal,
      closeAddMembersModal,
      isAddMembersModalVisible,
      selectedUserToAdd,
      isNewMemberModalVisible,
      createUsername,
      createEmail,
      createPassword,
      createUser,
      openCreateUserModal,
      closeCreateUserModal,
      deleteMember,
      closeDeleteUserModal,
      openDeleteUserModal,
      userToDelete,
      isDeleteUserModalOpen,

      editableMember,
      openEditMemberModal,
      updateMember,
      isEditMemberModalOpen,
      closeEditMemberModal,
      viewMember,
      promoteMember,
      demoteMember,
      formatRoles,
      authStore,
      errorMessages,
      successMessages,
      viewMemberCalendar
    };
  },
  data() {
    return {
      searchTeamQuery: '',
      searchQuery: '',
    };
  },
  methods: {



  },
};

</script>
