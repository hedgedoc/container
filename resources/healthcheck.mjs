import fetch from 'node-fetch'

// Kill myself after 5 second timeout
setTimeout(() => {
    process.exit(1)
}, 5000)

fetch(`http://localhost:${process.env.CMD_PORT || '3000' }/_health`, {headers: { "user-agent": "hedgedoc-container-healthcheck/1.1"}}).then((response) => {
    if (!response.ok) {
        process.exit(1)
    }
    return response.json()
}).then((data) => {
    if (!data.ready) {
        process.exit(1)
    }
    process.exit(0)
}).catch(() => {
    process.exit(1)
})
