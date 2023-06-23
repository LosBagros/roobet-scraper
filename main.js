require('dotenv').config();
const mysql = require('mysql2/promise');
const WebSocket = require('ws');
const socket = new WebSocket('wss://api.roobet.party/socket.io/?EIO=3&transport=websocket'); // Replace with your server's URL

let pool;

async function initialize() {
    pool = mysql.createPool({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASS,
        database: process.env.DB_NAME,
        waitForConnections: true,
        connectionLimit: 10,
        queueLimit: 0
    });
}

initialize();

socket.addEventListener('open', function(event) {
  console.log('Connected to the WebSocket server.');  
});

socket.addEventListener('message', function(event) {
  if (event.data.startsWith(42)) {
    const message = JSON.parse(event.data.substring(2));
    saveData(message);
  }
});

socket.addEventListener('close', function(event) {
  console.log('Disconnected from the WebSocket server.');
});

setInterval(() => {
  socket.send(2);
}, 20000);

async function saveData(data) {
  try {
      const connection = await pool.getConnection();
      try {
          let sql = 'INSERT INTO socket SET ?';
          await connection.query(sql, data);
          console.log('Data inserted successfully');
      } finally {
          // Ensure connection is released, even if error occurs while executing query.
          connection.release();
      }
  } catch (err) {
      // Handle error in any stage.
      console.error(err);
  }
}