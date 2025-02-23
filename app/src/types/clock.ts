export interface Clock {
	id: number;
	time: Date;
	status: boolean;
	to_check?: boolean;
}
