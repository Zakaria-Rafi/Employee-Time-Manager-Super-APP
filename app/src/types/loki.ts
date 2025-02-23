export interface RequestInQueue {
    method: "POST" | "PUT" | "DELETE",
    path: string,
    body?: object,
}