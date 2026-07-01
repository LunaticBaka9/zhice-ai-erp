import { ref, onUnmounted } from "vue"
import { Client } from "@stomp/stompjs"
import SockJS from "sockjs-client"

let stompClient = null

export function useNoticeWebSocket(onNewNotice) {
    const connected = ref(false)

    function connect() {
        if (stompClient?.active) return

        const token = localStorage.getItem("token")
        if (!token) return

        stompClient = new Client({
            webSocketFactory: () => new SockJS("/api/zhice-erp"),
            connectHeaders: { token },
            debug: () => {},
            reconnectDelay: 5000,
            heartbeatIncoming: 10000,
            heartbeatOutgoing: 10000,
            onConnect: () => {
                connected.value = true
                stompClient.subscribe("/topic/notices", (message) => {
                    try {
                        const data = JSON.parse(message.body)
                        if (onNewNotice) onNewNotice(data)
                    } catch {}
                })
            },
            onDisconnect: () => {
                connected.value = false
            },
            onStompError: () => {
                connected.value = false
            },
        })
        stompClient.activate()
    }

    function disconnect() {
        stompClient?.deactivate()
        connected.value = false
    }

    return { connected, connect, disconnect }
}
