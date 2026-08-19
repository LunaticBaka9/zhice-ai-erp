export function parseDate(v) {
	if (!v && v !== 0) return null
	if (v instanceof Date) return v
	if (typeof v === 'number') return new Date(v)
	const d = new Date(v)
	if (!isNaN(d.getTime())) return d
	return null
}

export function formatDate(v) {
	const d = parseDate(v)
	if (!d) return ''
	const y = d.getFullYear()
	const m = String(d.getMonth() + 1).padStart(2, '0')
	const day = String(d.getDate()).padStart(2, '0')
	return `${y}-${m}-${day}`
}

export function formatTime(v) {
	const d = parseDate(v)
	if (!d) return ''
	return d.toLocaleTimeString()
}

export function formatDateTime(v) {
	const d = parseDate(v)
	if (!d) return ''
	const y = d.getFullYear()
	const m = String(d.getMonth() + 1).padStart(2, '0')
	const day = String(d.getDate()).padStart(2, '0')
	const h = String(d.getHours()).padStart(2, '0')
	const min = String(d.getMinutes()).padStart(2, '0')
	return `${y}-${m}-${day} ${h}:${min}`
}

export function formatFileSize(bytes) {
	if (!bytes || bytes === 0) return '0 B'
	const k = 1024
	const sizes = ['B', 'KB', 'MB', 'GB']
	const i = Math.floor(Math.log(bytes) / Math.log(k))
	return (bytes / Math.pow(k, i)).toFixed(2) + ' ' + sizes[i]
}

export function formatPrice(price) {
	if (!price) return '0.00'
	return parseFloat(price).toFixed(2)
}

export function relativeTime(time) {
	const date = new Date(time)
	const now = new Date()
	const diff = now - date
	if (diff < 60 * 1000) return '刚刚'
	if (diff < 60 * 60 * 1000) return `${Math.floor(diff / (60 * 1000))}分钟前`
	if (diff < 24 * 60 * 60 * 1000) return `${Math.floor(diff / (60 * 60 * 1000))}小时前`
	if (diff < 7 * 24 * 60 * 60 * 1000) return `${Math.floor(diff / (24 * 60 * 60 * 1000))}天前`
	return `${date.getMonth() + 1}月${date.getDate()}日`
}

export default { parseDate, formatDate, formatTime, formatDateTime, formatFileSize, formatPrice, relativeTime }
