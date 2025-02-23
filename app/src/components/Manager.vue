<script>
import { ref, computed, onMounted } from 'vue';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import TeamService from '@/services/TeamService';
import UserService from '@/services/userService';
import { useAuthStore } from '@/stores/auth';
import { useRouter } from 'vue-router';

export default {
  components: {
    DataTable,
    Column,
  },
  setup() {
    const router = useRouter();

    const teamService = new TeamService();
    const userService = new UserService();
    const authStore = useAuthStore();

    // State Variables
    const manager = ref({});
    const teamMembers = ref([]);
    const selectedMembers = ref([]);
    const searchQuery = ref('');

    const isModalVisible = ref(false);
    const editableMember = ref({});


    const members = ref([]);
    const loading = ref(false);
    const error = ref(null);


    const detailedTeamMembers = ref([]);
    const filteredTeamUsers = ref([]);
    const isTeamModalVisible = ref(false);
    const Getmanager = computed(() => {
      return {
        username: authStore.user.username,
        role: "Manager",
      };
    });

    // Fetching data from services
    const FetchUsers = async () => {
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

    const fetchTeamMembers = async () => {
      loading.value = true;
      error.value = null;

      try {
        const teamsResponse = await teamService.getAll(); // Fetch all teams
        teamMembers.value = teamsResponse;

        // Fetch detailed info for each team
        const teamDetails = await Promise.all(
          teamMembers.value.map(async (team) => {
            const detailedInfo = await teamService.getById(team.id); // Fetch additional team details, including users
            return {
              ...detailedInfo,
              isExpanded: false, // Add an `isExpanded` property for toggling visibility
            };
          })
        );

        // Get the logged-in user
        const loggedInUser = authStore.user.username;

        // Filter teams where the logged-in user is a member
        detailedTeamMembers.value = teamDetails.filter(team => {
          return team.users.some(user => user.username === loggedInUser);
        });

      } catch (err) {
        error.value = 'Failed to load team details. Please try again later.';
      } finally {
        loading.value = false;
      }
    };

    const expandedRows = ref([]);
    // Expand All Rows
    const expandAll = () => {
      const allExpanded = {};
      detailedTeamMembers.value.forEach(team => {
        allExpanded[team.id] = true;
      });
      expandedRows.value = allExpanded; // Expand all rows
    };

    // Collapse All Rows
    const collapseAll = () => {
      expandedRows.value = {}; // Collapse all rows
    };




    onMounted(() => {
      FetchUsers();
      fetchTeamMembers();
    });





    const openeditMember = (member) => {
      editableMember.value = { ...member };
      isModalVisible.value = true;
    };

    const closeModal = () => {
      isModalVisible.value = false;
    };

    const updateMember = async () => {
      if (!editableMember.value.username || !editableMember.value.email) {
        console.error(editableMember.value);
        console.error('Please provide a username and email');
        return;
      }

      try {
        await userService.update(
          editableMember.value.id,
          editableMember.value.username,
          editableMember.value.email,
        );
        isModalVisible.value = false;
        FetchUsers();
        fetchTeamMembers();

        editableMember.value = {};
      } catch (error) {

        console.error('Update failed:', error);
      }
    };

    const onSelectionChange = (selectedMembers) => {
      selectedMembers.value = selectedMembers;
    };


    const openUserCalendar = (user) => {
      router.push({ name: 'workingTimes', params: { userId: user.id } });
    };
    const openUserDash = (user) => {
      router.push({ name: 'dashboard', params: { userId: user.id } });
    };

    return {
      Getmanager,
      manager,
      teamMembers,
      selectedMembers,
      searchQuery,
      isModalVisible,
      editableMember,
      openeditMember,
      updateMember,
      closeModal,
      onSelectionChange,
      members,
      detailedTeamMembers,
      expandedRows,
      expandAll,
      collapseAll,
      openUserCalendar,
      isTeamModalVisible,
      openUserDash,

    };
  },
};
</script>