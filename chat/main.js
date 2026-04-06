import init, { start_chat, send_message } from './pkg/wasm.js';

let isConnected = false;
let localPeerId = null;

const messagesDiv = document.getElementById('messages');
const chatWindow = document.getElementById('chat-window');
const input = document.getElementById('input');
const sendBtn = document.getElementById('send-btn');
const relayInput = document.getElementById('relay-addr');
const connectBtn = document.getElementById('connect-btn');
const statusSpan = document.getElementById('status');

// Your AWS Relay Address
const RELAY_ADDR = "/ip4/13.53.174.94/tcp/8001/ws/p2p/12D3KooWBN8pY3dYdE2XmFWefvRdo8vy5N3aQHgQyiQYN6vEYYha";

function addMessage(sender, content, type = 'received') {
    const div = document.createElement('div');
    div.className = `msg ${type}`;
    
    const senderSpan = document.createElement('span');
    senderSpan.className = 'sender';
    senderSpan.textContent = sender;
    div.appendChild(senderSpan);
    
    const contentDiv = document.createElement('div');
    contentDiv.textContent = content;
    div.appendChild(contentDiv);
    
    messagesDiv.appendChild(div);
    chatWindow.scrollTop = chatWindow.scrollHeight;
}

/**
 * Fetches history from the relay's inbox. 
 * Note: Since the relay returns HTML, we attempt to parse it or just link to it.
 * Browsers may block this due to CORS unless the relay sends 'Access-Control-Allow-Origin'.
 */
async function fetchHistory() {
    console.log('Fetching history from http://maks-relay.duckdns.org:8080/inbox');
    // If CORS is an issue, the user can always click the 'History' link at the top.
}

async function main() {
    // Set default value in the input field
    relayInput.value = RELAY_ADDR;

    try {
        await init();
        console.log('WASM Initialized');
    } catch (err) {
        console.error('WASM Init Failed:', err);
        statusSpan.textContent = 'Init Failed';
        return;
    }

    connectBtn.onclick = async () => {
        let addr = relayInput.value.trim();
        if (!addr) addr = RELAY_ADDR;

        connectBtn.disabled = true;
        relayInput.disabled = true;
        statusSpan.textContent = 'Connecting...';

        try {
            const onMessage = (peerId, sender, content) => {
                localPeerId = peerId;
                if (sender === localPeerId) return;
                addMessage(sender.substring(0, 8) + '…', content, 'received');
            };

            // Start the background chat process
            start_chat(addr, onMessage).catch(err => {
                console.error('Chat error:', err);
                statusSpan.textContent = 'Error: ' + err;
                connectBtn.disabled = false;
                relayInput.disabled = false;
                isConnected = false;
                input.disabled = true;
                sendBtn.disabled = true;
            });

            // We assume connection success if start_chat doesn't throw immediately
            isConnected = true;
            statusSpan.textContent = 'Connected';
            statusSpan.style.color = '#45a0cc';
            input.disabled = false;
            sendBtn.disabled = false;
            
            fetchHistory();

        } catch (err) {
            console.error('Connection failed:', err);
            statusSpan.textContent = 'Failed';
            connectBtn.disabled = false;
            relayInput.disabled = false;
        }
    };

    const sendMessageAction = () => {
        const content = input.value.trim();
        if (content && isConnected) {
            try {
                send_message(content);
                addMessage('You', content, 'sent');
                input.value = '';
            } catch (err) {
                console.error('Send error:', err);
                alert('Failed to send message: ' + err);
            }
        }
    };

    sendBtn.onclick = sendMessageAction;
    input.onkeypress = (e) => {
        if (e.key === 'Enter') sendMessageAction();
    };
}

main().catch(console.error);
