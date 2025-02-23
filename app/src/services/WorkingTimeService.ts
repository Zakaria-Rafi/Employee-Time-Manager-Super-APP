import type { WorkingTime } from "@/types/workingTime";
import apiClient from "@/services/apiClient";
import type { workingtimeClock } from "@/types/workingtimesClocks";

class WorkingTimeService {
	async create(
		userId: number,
		start: string,
		end: string,
	): Promise<WorkingTime> {
		const response = await apiClient.post(`/workingtime/${userId}`, {
			start,
			end,
		});

		return response.data;
	}

	async update(id: number, data: Partial<WorkingTime>): Promise<WorkingTime> {
		const response = await apiClient.put(`/workingtime/${id}`, data);
		return response.data;
	}

	async delete(id: number): Promise<WorkingTime> {
		const response = await apiClient.delete(`/workingtime/${id}`);
		return response.data;
	}

	async getAll(userId: number, period: any): Promise<Array<WorkingTime>> {
		const response = await apiClient.get(
			`/workingtime/${userId}?page_size=100`,
			{
				params: period,
			},
		);
		return response.data.items;
	}

	async getById(userId: number, workingTimeId: number): Promise<WorkingTime> {
		const response = await apiClient.get(
			`/workingtime/${userId}/${workingTimeId}`,
		);
		return response.data;
	}
	async getClocks(userId: number, period: any): Promise<workingtimeClock[]> {
		const response = await apiClient.get(`/workingtime/${userId}/clocks`, {
			params: period,
		});
		return response.data.items;
	}
}

export default WorkingTimeService;
