import request from "@/utils/request";

export function getSupplierList(params) {
    return request.get("/supplier/list", { params });
}

export function getAllSuppliers() {
    return request.get("/supplier/selectAllCustomer");
}

export function addSupplier(data) {
    return request.post("/supplier/add", data);
}

export function updateSupplier(data) {
    return request.post("/supplier/update", data);
}

export function deleteSupplier(id) {
    return request.delete(`/supplier/delete/${id}`);
}
