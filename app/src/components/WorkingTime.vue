<script setup lang="ts" xmlns="http://www.w3.org/1999/html">

import WorkingTimeService from "@/services/WorkingTimeService";
import type {WorkingTime} from "@/types/workingTime";
import moment from "moment";
import {onMounted, ref, } from "vue";
import { useRoute, useRouter } from "vue-router"
import Button from "primevue/button"
import DatePicker from "primevue/datepicker"
import FloatLabel from "primevue/floatlabel"

const route = useRoute()
const router = useRouter()
const userId = parseInt(route.params.userId as string)
const workingTimeId = parseInt(route.params.workingTimeId as string)
const workingTimeService = new WorkingTimeService()

const id = ref<number>()
const startedAt = ref<string>()
const endedAt = ref()

onMounted(async () => {
  const response = await getWorkingTime();
  id.value = response.id
  startedAt.value = moment(response.start).format("YYYY-MM-DD")
  endedAt.value = moment(response.end).format("YYYY-MM-DD")
});

async function getWorkingTime(): Promise<WorkingTime> {
  return await workingTimeService.getById(userId, workingTimeId)
}

async function updateWorkingTime(id: number) {
  const data: Partial<WorkingTime> = { start: moment(startedAt.value).unix().toString(), end: moment(endedAt.value).unix().toString() }
  await workingTimeService.update(id, data)
}

async function deleteWorkingTime(id: number) {
  await workingTimeService.delete(id)
  await router.push({ name: "workingTimes", params: { userId }})
}

</script>

<template>
  <div v-if="id" id="workingTimeForm" class="flex flex-col w-1/2 mx-auto items-center gap-y-10 mt-10">
    <h2 class="text-2xl">WorkingTime {{ id }}</h2>
    <div class="flex gap-10">
      <FloatLabel>
        <DatePicker name="start" v-model="startedAt" showTime />
        <label for="start">Start</label>
      </FloatLabel>
      <FloatLabel>
        <DatePicker name="end" v-model="endedAt" showTime />
        <label for="end">End</label>
      </FloatLabel>
    </div>
    <div id="buttons" class="flex w-1/2 mx-auto justify-around">
      <Button @click="updateWorkingTime(id)">Update</Button>
      <Button @click="deleteWorkingTime(id)" label="Delete" class="bg-red-700"/>
    </div>
  </div>


</template>

<style scoped>

</style>