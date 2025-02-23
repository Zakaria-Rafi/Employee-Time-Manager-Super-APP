import apiClient from './apiClient';
import type {Team} from '@/types/Team';

class TeamService {
    // Get all teams
    async getAll(): Promise<Team[]> {
        const response = await apiClient.get('/teams');
        return response.data.items;
    }

    // Get a team by ID
    async getById(id: number): Promise<Team> {
        const response = await apiClient.get(`/teams/${id}`);
        return response.data;
    }

    async create(name: string): Promise<Team> {
        const formData = new FormData();
        formData.append('name', name);
        const response = await apiClient.post('/teams', formData);
        return response.data;
    }
    

    // Update a team by ID
    async update(id: number, teamData: { name?: string; description?: string }): Promise<Team> {
        const response = await apiClient.put(`/teams/${id}`, teamData);
        return response.data;
    }

    // Add a user to a team
    async addUser(teamId: number, userId: number): Promise<void> {
        const response = await apiClient.put(`/teams/${teamId}/add/${userId}`);
        return response.data;
    }

    // Remove a user from a team
    async removeUser(teamId: number, userId: number): Promise<void> {
        const response = await apiClient.delete(`/teams/${teamId}/remove/${userId}`);
        return response.data;
    }

    // Delete a team by ID
    async delete(id: number): Promise<void> {
        const response = await apiClient.delete(`/teams/${id}`);
        return response.data;
    }
}

export default TeamService;
