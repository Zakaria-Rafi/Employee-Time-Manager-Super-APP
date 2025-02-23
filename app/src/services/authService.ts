import apiClient from "@/services/apiClient";

class AuthService {
    async login(email: string, password: string) {
        return await apiClient.post('/login', { email, password })
    }

    async logout() {
        return await apiClient.delete('/logout')
    }
}

export default AuthService