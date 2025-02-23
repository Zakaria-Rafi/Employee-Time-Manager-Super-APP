export interface calendarEvent {
	id: string;
	title: string;
	start: any;
	end: any;
	color?: string;
	allDay: boolean;
	// tovalidate is boolean and its false by default
	toValidate?: boolean;
}
