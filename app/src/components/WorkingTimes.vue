<script setup lang="ts">
import { ref, onMounted } from 'vue';
import WorkingTimeService from '@/services/WorkingTimeService';
import type { WorkingTime } from '@/types/workingTime';
import moment from "moment";
import Button from "primevue/button"
import DataTable from "primevue/datatable"
import Column from "primevue/column"
import {useRouter} from "vue-router"

const { userId } = defineProps<{ userId: number }>()
const router = useRouter()

const workingTimesList = ref<Array<WorkingTime>>([]);
const startedAtRef = ref(moment().startOf('month'))
const endedAtRef = ref(moment().endOf('month'))

const workingTimeService = new WorkingTimeService();

async function getWorkingTimes () {
  workingTimesList.value = await workingTimeService.getAll(userId, {
    start: startedAtRef.value.unix(),
    end: endedAtRef.value.unix()
  });
}

async function updateWorkingTime (e: any) {
  startedAtRef.value = moment(e.target.start.value)
  endedAtRef.value = moment(e.target.end.value)
  await getWorkingTimes()
}

onMounted(async () => {
  await getWorkingTimes();
});

async function redirectToWorkingTime(e: any) {
  const workingTimeId = e.data.id
  await router.push({ name: "editWorkingTime", params: { userId, workingTimeId }})
}

async function redirectToCreate() {
  await router.push({ name: "createWorkingTime", params: { userId }})
}
</script>

<template>
  <form method="get" @submit.prevent="updateWorkingTime">
    <input name="start" type="date" :value="startedAtRef.format('YYYY-MM-DD')">
    <input name="end" type="date" :value="endedAtRef.format('YYYY-MM-DD')">
    <Button type="submit">Update period</Button>
  </form>

  <Button @click="redirectToCreate()">Create a working time</Button>

  <div id="tableContainer" class="w-auto mx-auto">
    <DataTable :value="workingTimesList" tableStyle="min-width: 50rem" dataKey="id" @row-click="redirectToWorkingTime" selection-mode="single">
      <Column header="Date">
        <template #body="slotProps">
          {{moment(slotProps.data.start).format("DD/MM/YY")}}
        </template>
      </Column>
      <Column header="Start">
        <template #body="slotProps">
          {{moment(slotProps.data.start).format("HH:mm")}}
        </template>
      </Column>
      <Column header="Name">
        <template #body="slotProps">
          {{moment(slotProps.data.end).format("HH:mm")}}
        </template>
      </Column>
    </DataTable>
  </div>
</template>

<style scoped>
</style>
