import request from "@/utils/request";

export function getCustomerList(params) {
    return request.get("/customer/list", { params });
}

export function getAllCustomers() {
    return request.get("/customer/selectAllCustomer");
}

export function addCustomer(data) {
    return request.post("/customer/add", data);
}

export function updateCustomer(data) {
    return request.post("/customer/update", data);
}

export function deleteCustomer(id) {
    return request.delete(`/customer/${id}`);
}
