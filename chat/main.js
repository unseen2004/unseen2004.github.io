import init, { start_chat, send_message } from './pkg/wasm.js';

let isConnected = false;
let localPeerId = null;

const messagesDiv = document.getElementById('messages');
const chatWindow = document.getElementById('chat-window');
const input = document.getElementById('input');
const sendBtn = document.getElementById('send-btn');
const statusSpan = document.getElementById('status');

// Your AWS Relay Address (Secure WSS)
const RELAY_ADDR = "/dns4/maks-relay.duckdns.org/tcp/443/wss/p2p/12D3KooWGUMaygJft6EXAxCSMoxmjyJKhkyEuv2qT3W8oTXA1zXY";

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

async function main() {
    try {
        statusSpan.textContent = 'Initializing...';
        await init();
        console.log('WASM Initialized');
        
        statusSpan.textContent = 'Connecting...';
        console.log('Attempting to connect to:', RELAY_ADDR);
        
        const onMessage = (peerId, sender, content) => {
            localPeerId = peerId;
            if (sender === localPeerId) return;
            addMessage(sender.substring(0, 8) + '…', content, 'received');
        };

        // Add a safety timeout so it doesn't hang forever
        const connectionTimeout = setTimeout(() => {
            if (!isConnected) {
                console.error('Connection timed out after 15 seconds');
                statusSpan.textContent = 'Timeout';
                statusSpan.style.color = '#cc8845';
            }
        }, 15000);

        try {
            await start_chat(RELAY_ADDR, onMessage);
            clearTimeout(connectionTimeout);
            
            isConnected = true;
            statusSpan.textContent = 'Online';
            statusSpan.style.color = '#45a0cc';
            input.disabled = false;
            sendBtn.disabled = false;
            console.log('Connected successfully!');
        } catch (e) {
            clearTimeout(connectionTimeout);
            throw e; // Pass to the catch block below
        }

    } catch (err) {
        console.error('Connection Failed Detailed Error:', err);
        statusSpan.textContent = 'Offline';
        statusSpan.style.color = '#cc4545';
        input.disabled = true;
        sendBtn.disabled = true;
    }

    const sendMessageAction = () => {
        const content = input.value.trim();
        if (content && isConnected) {
            try {
                send_message(content);
                addMessage('You', content, 'sent');
                input.value = '';
            } catch (err) {
                console.error('Send error:', err);
                alert('Failed to send: ' + err);
            }
        }
    };

    sendBtn.onclick = sendMessageAction;
    input.onkeypress = (e) => {
        if (e.key === 'Enter') sendMessageAction();
    };
}

main().catch(console.error);
