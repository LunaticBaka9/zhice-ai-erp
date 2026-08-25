import request from "@/utils/request";

export function getCategoryTree() {
    return request.get("/category/tree");
}
