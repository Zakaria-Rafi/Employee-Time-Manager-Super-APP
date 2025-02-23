<template>

  </template>
  
  <script setup lang="ts">
  import UserService from '@/services/userService';
import { ref, onMounted } from 'vue';
  import { useRoute } from 'vue-router';
  
  // Define User interface
  interface User {
    id: number;
    username: string;
    email: string;
  }
  
  const username = ref('');
  const email = ref('');
  const password = ref('');
  const userId = ref<number | null>(null);
  const message = ref('');
  const loading = ref(false);
  const fetchedUser = ref<User | null>(null);
  
  const route = useRoute();
  
  async function updateUser() {
    if (userId.value !== null) {
      const userService = new UserService();
      loading.value = true;
      message.value = '';
  
      if (!username.value || !email.value) {
        message.value = 'All fields are required.';
        loading.value = false;
        return;
      }
  
      try {
        await userService.update(userId.value, username.value, email.value, password.value);
        message.value = 'User updated successfully!';
  
        await getUser(); // Refresh the user information from the server
      } catch (error) {
        const err = error as { response?: { data?: { error: string } } };
        message.value = err.response?.data?.error || 'Error updating user: Unknown error occurred.';
      } finally {
        loading.value = false;
      }
    } else {
      message.value = 'User ID is required.';
    }
  }
  async function getUser() {
    const userService = new UserService();
    loading.value = true;
    message.value = '';
  
    try {
      if (userId.value !== null) {
        const user = await userService.get(userId.value);
        fetchedUser.value = user; // Store fetched user data
        username.value = user.username; // Populate username input
        email.value = user.email; // Populate email input
        // Removed the message setting line
      } else {
        message.value = 'User ID is required.';
      }
    } catch (error) {
      const err = error as { response?: { data?: { error: string } } };
      message.value = err.response?.data?.error || 'Error retrieving user: Unknown error occurred.';
    } finally {
      loading.value = false;
    }
  }
  

  
  // Fetch user information based on ID in URL when component mounts
  onMounted(() => {
    const id = Number(route.params.id);
    if (!isNaN(id)) {
      userId.value = id; // Set userId from route params
      getUser(); // Fetch user data
    }
  });
  </script>
  
  <style scoped>
  </style>
  