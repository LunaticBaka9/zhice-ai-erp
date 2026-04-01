export function parseDate(v) {
    if (!v && v !== 0) return null;
    if (v instanceof Date) return v;
    // numbers (timestamp)
    if (typeof v === "number") return new Date(v);
    // try ISO or other date string
    const d = new Date(v);
    if (!isNaN(d.getTime())) return d;
    return null;
}

export function formatDate(v) {
    const d = parseDate(v);
    if (!d) return "";
    return d.toLocaleDateString();
}

export function formatTime(v) {
    const d = parseDate(v);
    if (!d) return "";
    return d.toLocaleTimeString();
}

export function formatDateTime(v) {
    const d = parseDate(v);
    if (!d) return "";
    return d.toLocaleString();
}

export default { parseDate, formatDate, formatTime, formatDateTime };
