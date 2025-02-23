import type { User } from '@/types/user';
import apiClient from './apiClient';
import type { Team } from '@/types/Team';
import { UserRole } from '@/types/userRole';


class UserService {
    //create a new user
    async create(username: string, email: string, password: string): Promise<User> {
        const response = await apiClient.post('/users', { username, email, password });
        return response.data;
    }
    //update a user
    async update(id: number, username: string, email: string, password: string): Promise<User> {
        const response = await apiClient.put(`/users/${id}`, { username, email, password });
        return response.data;
    }
    //get a user by id
    async get(id: number): Promise<User> {
        const response = await apiClient.get(`/users/${id}`);
        return response.data;
    }
    //get a user by email and username
    async getByEmailAndUsername(email: string, username: string): Promise<User> {
        const response = await apiClient.get('/users', { params: { email, username } });
        return response.data;
    }
    //delete a user
    async delete(id: number): Promise<void> {
        const response = await apiClient.delete(`/users/${id}`);
        return response.data;
    }

    async me() {
        return await apiClient.get('/users/me')
    }

    async getAll(): Promise<User[]> {
        const response = await apiClient.get('/users');
        return response.data.items;
    }

    async getUserTeams(userId: number): Promise<Team[]> {
        const response = await apiClient.get(`/users/${userId}/teams`);
        return response.data;
    }

    // Promote a user
    async promote(id: number, newRole:string): Promise<User> {
        const response = await apiClient.put(`/users/${id}/promote`,{role:newRole});
        return response.data;
    }

    // Demote a user
    async demote(id: number, roleToDemote:string): Promise<User> {
        const response = await apiClient.put(`/users/${id}/demote`,{role:roleToDemote});
        return response.data;
    }

    isEmployee(userRoles: UserRole[]) {
        return userRoles.includes(UserRole.ROLE_USER)
                && !userRoles.includes(UserRole.ROLE_MANAGER)
                && !userRoles.includes(UserRole.ROLE_SUPERMANAGER)
    }
    
    isManager(userRoles: UserRole[]) {
        return userRoles.includes(UserRole.ROLE_MANAGER)
                && !userRoles.includes(UserRole.ROLE_SUPERMANAGER)
    }
}

export default UserService;