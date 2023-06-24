require("dotenv").config();
const mysql = require("mysql2/promise");
const WebSocket = require("ws");

let pool;

async function initialize() {
  pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: "root",
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
  });
  connectSocket();
}

initialize();
function connectSocket() {
  const socket = new WebSocket(
    "wss://api.roobet.party/socket.io/?EIO=3&transport=websocket"
  ); // Replace with your server's URL

  socket.addEventListener("open", function (event) {
    console.log("Connected to the WebSocket server.");
  });

  socket.addEventListener("message", function (event) {
    if (event.data.startsWith(42)) {
      const message = JSON.parse(event.data.substring(2));
      if (message[0] === "new_bet") {
        saveData(message[1]);
      }
      if (message[0] === "settingsUpdated") {
        saveSettings(message[1]);
      }
      if (message[0] === "chat_message") {
        saveChat(message[1]);
      }
    }
  });

  socket.addEventListener("close", function (event) {
    console.log("Disconnected from the WebSocket server.");
        connectSocket();
  });

  setInterval(() => {
    socket.send(2);
  }, 20000);
}

async function saveData(data) {
  const connection = await pool.getConnection();

  try {
    const {
      _id,
      betAmount,
      balanceType,
      currency,
      closedOut,
      closeoutComplete,
      paidOut,
      ranHooks,
      attempts,
      betId,
      gameName,
      gameNameDisplay,
      transactionIds,
      thirdParty,
      category,
      gameIdentifier,
      payoutValue,
      mult,
      profit,
      gameSessionId,
      userId,
      won,
      twoFactor,
      ...otherData
    } = data;
    const username = data.user && data.user.name;

    // Handle user data
    const userSQL = `
      INSERT INTO users (id, name, twoFactor) VALUES (?, ?, ?)
      ON DUPLICATE KEY UPDATE name = VALUES(name), twoFactor = VALUES(twoFactor);
    `;
    const userParams = [userId || null, username || null, twoFactor || null];
    await connection.query(userSQL, userParams);

    // Handle bet data
    const betSQL = `
      INSERT INTO bet (_id, betAmount, balanceType, currency, closedOut, closeoutComplete,
      paidOut, ranHooks, attempts, betId, gameName, gameNameDisplay, transactionIds,
      thirdParty, category, gameIdentifier, payoutValue, mult, profit,
      gameSessionId, userId, won)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
    `;
    const betParams = [
      _id || null,
      betAmount || null,
      balanceType || null,
      currency || null,
      closedOut || null,
      closeoutComplete || null,
      paidOut || null,
      ranHooks || null,
      attempts || null,
      betId || null,
      gameName || null,
      gameNameDisplay || null,
      transactionIds ? JSON.stringify(transactionIds) : null,
      thirdParty || null,
      category || null,
      gameIdentifier || null,
      payoutValue || null,
      mult || null,
      profit || null,
      gameSessionId || null,
      userId || null,
      won || null,
    ];
    await connection.query(betSQL, betParams);

    // console.log(`Saved data for user: ${userId}`);
  } catch (error) {
    console.error(`Failed to insert data: ${error}`);
  } finally {
    if (connection) {
      connection.release();
    }
  }
}

async function saveSettings(data) {
  const connection = await pool.getConnection();

  try {
    const allTimeNumBets = data.globalStats.allTimeNumBets;
    if (allTimeNumBets == null) {
      return;
    }
    const settingsSQL = `
      INSERT INTO totalbets (allTimeNumBets)
      VALUES (?)
    `;
    await connection.query(settingsSQL, [allTimeNumBets]);
  } catch (error) {
    console.error(`Failed to insert settings: ${error}`);
  } finally {
    if (connection) {
      connection.release();
    }
  }
}

async function saveChat(chatData) {
  const connection = await pool.getConnection();

  try {
    const {
      id,
      message,
      userId,
      type,
      userStatus,
      locale,
    } = chatData;

    const username = chatData.user && chatData.user.name;
    const userSQL = `
      INSERT INTO users (id, name) VALUES (?, ?)
      ON DUPLICATE KEY UPDATE name = VALUES(name);
    `;
    const userParams = [userId || null, username || null];
    await connection.query(userSQL, userParams);

    // Handle chat data
    const chatSQL = `
      INSERT INTO chat (id, message, userId, type, userStatus, locale)
      VALUES (?, ?, ?, ?, ?, ?);
    `;
    const chatParams = [
      id || null,
      message || null,
      userId || null,
      type || null,
      userStatus || null,
      locale || null
    ];
    await connection.query(chatSQL, chatParams);

    // console.log(`Saved chat message from user: ${userId}`);
  } catch (error) {
    console.error(`Failed to insert chat data: ${error}`);
  } finally {
    if (connection) {
      connection.release();
    }
  }
}
