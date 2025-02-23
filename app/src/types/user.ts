import type { UserRole } from "./userRole";

export interface User {
	id: number;
	username: string;
	email: string;
	currently_working: boolean;
	last_login: string | null;
	roles: Array<UserRole>;
	created_at: string;
	updated_at: string | null;
}
