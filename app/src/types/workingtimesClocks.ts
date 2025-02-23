import type { Clock } from "@/types/clock";
export interface workingtimeClock {
	id: number;
	start: Date;
	end: Date;
	clocks: Clock[];
	created_at: Date;
	updated_at: Date;
	total_clocked_time: number;
	total_worked_time: number;
}
