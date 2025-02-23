<script setup lang="ts">
import WorkingTimeService from "@/services/WorkingTimeService";
import { onMounted, ref } from "vue";
import { endOfDay, format, startOfDay, subDays } from "date-fns";
import type { WorkingTime } from "@/types/workingTime";
import type { workingtimeClock } from "@/types/workingtimesClocks";
import { ChartType } from "@/types/ChartType";
import Chart from "primevue/chart";
import moment from "moment";

const { userId, chartType } = defineProps<{
	userId: number;
	chartType: ChartType;
}>();

const workingTimeService = new WorkingTimeService();
const barChartData: any = ref(null);
const dailyGaugeData: any = ref(null);
const tenDayGaugeData: any = ref(null);
const chartOptions: any = ref({
	maintainAspectRatio: false,
	plugins: {
		legend: {
			labels: {
				color: "#FFFFFF",
			},
		},
		tooltip: {
			titleColor: "#FFFFFF",
			bodyColor: "#FFFFFF",
		},
	},
	scales: {
		x: {
			ticks: {
				color: "#FFFFFF",
			},
		},
		y: {
			ticks: {
				color: "#FFFFFF",
			},
		},
	},
});

const gaugeChartOptions = ref({
	responsive: true,
	maintainAspectRatio: true,
	cutout: "75%",
	plugins: {
		legend: {
			labels: {
				color: "#FFFFFF", // White color for legend labels
			},
		},
		tooltip: {
			titleColor: "#FFFFFF", // White color for tooltip title
			bodyColor: "#FFFFFF", // White color for tooltip body text
		},
	},
});

const fetchWorkingTimeData = async () => {
	try {
		const today = new Date();
		const currentDayStart = moment().startOf("day").unix();
		const endOfWeek = moment().endOf("week").unix();
		const startOfWeek = moment().startOf("week").unix();

		console.log("Fetching data from:", {
			startOfWeek,
			endOfWeek,
			currentDayStart,
		});

		const clocks: Array<workingtimeClock> = await workingTimeService.getClocks(
			userId,
			{ start: startOfWeek, end: endOfWeek },
		);

		// Aggregate data by date
		const aggregatedData: {
			[date: string]: { workedTime: number; clockedTime: number };
		} = {};
		clocks.forEach((clock) => {
			const date = format(new Date(clock.start), "dd/MM/yyyy");

			if (!aggregatedData[date]) {
				aggregatedData[date] = { workedTime: 0, clockedTime: 0 };
			}

			aggregatedData[date].workedTime += clock.total_worked_time / 3600;
			aggregatedData[date].clockedTime += clock.total_clocked_time / 3600;
		});

		// Create data for charts from aggregated data
		const barChartDataItems = Object.keys(aggregatedData).map((day) => ({
			day,
			...aggregatedData[day],
		}));

		barChartData.value = {
			labels: barChartDataItems.map((item) => item.day),
			datasets: [
				{
					label: "Working Time",
					backgroundColor: "#FFA726",
					data: barChartDataItems.map((item) => item.workedTime),
				},
				{
					label: "Clocked Time",
					backgroundColor: "#66BB6A",
					data: barChartDataItems.map((item) => item.clockedTime),
				},
			],
		};

		const todayData = aggregatedData[format(today, "dd/MM/yyyy")] || {
			workedTime: 0,
			clockedTime: 0,
		};
		const dailyProgressPercent = todayData.workedTime
			? (todayData.clockedTime * 100) / todayData.workedTime
			: 0;

		dailyGaugeData.value = {
			labels: ["Clocked Time", "Remaining Time"],
			datasets: [
				{
					data: [
						dailyProgressPercent.toFixed(1),
						100 - dailyProgressPercent < 0
							? 0
							: (100 - dailyProgressPercent).toFixed(1),
					],
					backgroundColor: ["#66BB6A", "#FFA726"],
				},
			],
			actualData: todayData, // Store actual hours for tooltip display
		};

		const totalWorkedTime = Object.values(aggregatedData).reduce(
			(acc, dayData) => acc + dayData.workedTime,
			0,
		);
		const totalClockedTime = Object.values(aggregatedData).reduce(
			(acc, dayData) => acc + dayData.clockedTime,
			0,
		);
		const weeklyProgressPercent = totalWorkedTime
			? (totalClockedTime * 100) / totalWorkedTime
			: 0;

		tenDayGaugeData.value = {
			labels: ["Clocked Time", "Remaining Time"],
			datasets: [
				{
					data: [
						weeklyProgressPercent.toFixed(1),
						100 - weeklyProgressPercent < 0
							? 0
							: (100 - weeklyProgressPercent).toFixed(1),
					],
					backgroundColor: ["#66BB6A", "#FFA726"],
				},
			],
			actualData: {
				workedTime: totalWorkedTime,
				clockedTime: totalClockedTime,
			},
		};
	} catch (error) {
		console.error("Error fetching working time data:", error);
	}
};

onMounted(() => fetchWorkingTimeData());
</script>

<template>
	<div id="charts">
		<!-- Bar Chart for Daily Working Hours -->
		<p v-if="chartType === ChartType.BAR" class="chartTitle">
			Working Hours Per Day
		</p>
		<div v-if="chartType === ChartType.BAR" class="chartContainer">
			<Chart
				type="bar"
				:data="barChartData"
				:options="chartOptions"
				class="chart text-secondary"
			/>
		</div>

		<!-- Daily Gauge (Doughnut Chart) for Daily Work Limit -->
		<p v-if="chartType === ChartType.DOUGHNUT_DAY" id="dayTitle" class="chartTitle">
			Daily Work Progress(%)
		</p>
		<div v-if="chartType === ChartType.DOUGHNUT_DAY" class="chartContainer">
			<Chart
				type="doughnut"
				:data="dailyGaugeData"
				:options="gaugeChartOptions"
				class="doughnutChart"
				style="width: 100%; height: 100%"
			/>
		</div>

		<!-- Weekly Gauge (Doughnut Chart) for Weekly Work Limit -->
		<p v-if="chartType === ChartType.DOUGHNUT_WEEK" id="weekTitle" class="chartTitle">
			Weekly Work Progress(%)
		</p>
		<div v-if="chartType === ChartType.DOUGHNUT_WEEK" class="chartContainer">
			<Chart
				type="doughnut"
				:data="tenDayGaugeData"
				:options="gaugeChartOptions"
				class="doughnutChart text-white"
				style="width: 100%; height: 100%"
			/>
		</div>
	</div>
</template>

<style scoped>
.chartContainer {
	height: 32vh;
	border-radius: 20px;
	padding: 2%;
	@apply bg-primary text-secondary;
}

.chartTitle {
	font-size: 1.5rem;
	@apply font-medium text-primary mb-2;
}

.chart {
	height: 100%;
}

.doughnutChart * {
	margin: auto;
}
</style>
