import init, { start_chat, send_message } from './pkg/wasm.js';

let isConnected = false;
let localPeerId = null;

const messagesDiv = document.getElementById('messages');
const chatWindow = document.getElementById('chat-window');
const input = document.getElementById('input');
const sendBtn = document.getElementById('send-btn');
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

async function main() {
    try {
        statusSpan.textContent = 'Initializing...';
        await init();
        console.log('WASM Initialized');
        
        statusSpan.textContent = 'Connecting...';
        
        const onMessage = (peerId, sender, content) => {
            localPeerId = peerId;
            if (sender === localPeerId) return;
            addMessage(sender.substring(0, 8) + '…', content, 'received');
        };

        // Start the background chat process automatically
        start_chat(RELAY_ADDR, onMessage).catch(err => {
            console.error('Chat error:', err);
            statusSpan.textContent = 'Offline';
            isConnected = false;
            input.disabled = true;
            sendBtn.disabled = true;
        });

        // We assume connection intent is successful
        isConnected = true;
        statusSpan.textContent = 'Online';
        statusSpan.style.color = '#45a0cc';
        input.disabled = false;
        sendBtn.disabled = false;

    } catch (err) {
        console.error('Init Failed:', err);
        statusSpan.textContent = 'Error';
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
