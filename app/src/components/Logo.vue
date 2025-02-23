<script setup lang="ts">
import Image from "primevue/image"
import lightLogo from "@/assets/light_logo.png"
import darkLogo from "@/assets/dark_logo.png"

const props = defineProps<{ type: 'light' | 'dark' }>()

const logoImg = props.type === 'light' ? lightLogo : darkLogo
</script>

<template>
	<Image :src="logoImg" id="logo" class="w-24"></Image>
</template>

<style scoped></style>
