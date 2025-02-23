<script setup lang="ts">
import {useRoute, useRouter} from "vue-router"
import FloatLabel from "primevue/floatlabel";
import DatePicker from "primevue/datepicker";
import Button from "primevue/button";
import moment from "moment";
import {ref} from "vue";
import WorkingTimeService from "@/services/WorkingTimeService";

const route = useRoute()
const router = useRouter()

const userId = parseInt(route.params.userId as string)
const workingTimeService = new WorkingTimeService()

const startedAt = ref()
const endedAt = ref()

async function createWorkingTime() {
  await workingTimeService.create(userId, moment(startedAt.value).unix().toString(), moment(endedAt.value).unix().toString())
  await router.push({ name: "workingTimes", params: { userId }})
}
</script>

<template>
  <div id="formCreateWorkingTime" class="flex flex-col w-1/2 mx-auto items-center gap-y-10 mt-10">
    <h2>Add a Working Time</h2>
    <FloatLabel>
      <DatePicker name="start" v-model="startedAt" showTime dateFormat="dd/mm/yy" />
      <label for="start">Start</label>
    </FloatLabel>
    <FloatLabel>
      <DatePicker name="end" v-model="endedAt" showTime dateFormat="dd/mm/yy"/>
      <label for="end">End</label>
    </FloatLabel>
    <Button @click="createWorkingTime">Create</Button>
  </div>
</template>

<style scoped>

</style>