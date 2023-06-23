import asyncio
import websockets
import json
import mysql.connector


mydb = mysql.connector.connect(
  host="localhost",
  user="root",
  password="",
  database="roobet"
)


async def send_message(websocket):
    while True:
        try:
            print("Sending message")
            await websocket.send("2")
            await asyncio.sleep(25)
        except websockets.exceptions.ConnectionClosedOK:
            print("WebSocket connection closed with status code 1000 (OK). Attempting to reconnect...")
            await connect_to_websocket()


async def connect_to_websocket():
    while True:
        try:
            async with websockets.connect('wss://api.roobet.party/socket.io/?EIO=3&transport=websocket') as websocket:
                # Start the send_message coroutine in the background
                asyncio.create_task(send_message(websocket))

                while True:
                    message = await websocket.recv()
                    # Process the received message
                    # print(message)
                    if message.startswith('42'):
                        if message.find('new_bet') != -1:
                            data = json.loads(message[message.find('{'):message.rfind('}')+1])
                            mycursor = mydb.cursor()

                            id = data['userId']
                            if data['user'] is not None:
                                name = data['user']['name']
                            else:
                                name = None
                            twoFactor = data['twoFactor']

                            select_query = "SELECT * FROM users WHERE id = %s"
                            mycursor.execute(select_query, [id])
                            existing_user = mycursor.fetchone()

                            if existing_user:
                                if name:
                                    update_query = "UPDATE users SET name = %s WHERE id = %s"
                                    mycursor.execute(update_query, (name, id))
                                if twoFactor:
                                    update_query = "UPDATE users SET twoFactor = %s WHERE id = %s"
                                    mycursor.execute(update_query, (twoFactor, id))
                            else:
                                if name:
                                    insert_query = "INSERT INTO users (id, name, twoFactor) VALUES (%s, %s, %s)"
                                    mycursor.execute(insert_query, (id, name, twoFactor))
                                else:
                                    insert_query = "INSERT INTO users (id, twoFactor) VALUES (%s, %s)"
                                    mycursor.execute(insert_query, (id, twoFactor))

                            mydb.commit()
                            mycursor.close()
                            mycursor = mydb.cursor()

                            _id = data['_id']
                            betAmount = data['betAmount']
                            balanceType = data['balanceType']
                            currency = data['currency']
                            closedOut = data['closedOut']
                            closeoutComplete = data['closeoutComplete']
                            paidOut = data['paidOut']
                            ranHooks = data['ranHooks']
                            attempts = data['attempts']
                            betId = data['betId']
                            gameName = data['gameName']
                            try:
                                gameNameDisplay = data['gameNameDisplay']
                            except:
                                gameNameDisplay = None
                            transactionIds = data['transactionIds']
                            try:
                                thirdParty = data['thirdParty']
                            except:
                                thirdParty = None
                            try:
                                category = data['category']
                            except:
                                category = None
                            gameIdentifier = data['gameIdentifier']
                            payoutValue = data['payoutValue']
                            mult = data['mult']
                            profit = data['profit']
                            gameSessionId = data['gameSessionId']
                            userId = data['userId']
                            won = data['won']
                            timestamp = data['timestamp']
                            closeoutTimestamp = data['closeoutTimestamp']
                            createdAt = data['createdAt']
                            updatedAt = data['updatedAt']

                            insert_query = "INSERT INTO bet (_id, betAmount, balanceType, currency, closedOut, closeoutComplete, paidOut, ranHooks, attempts, betId, gameName, gameNameDisplay, transactionIds, thirdParty, category, gameIdentifier, payoutValue, mult, profit, gameSessionId, userId, won, timestamp, closeoutTimestamp, createdAt, updatedAt) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
                            mycursor.execute(insert_query, (_id, betAmount, balanceType, currency, closedOut, closeoutComplete, paidOut, ranHooks, attempts, betId, gameName, gameNameDisplay, json.dumps(transactionIds), thirdParty, category, gameIdentifier, payoutValue, mult, profit, gameSessionId, userId, won, timestamp, closeoutTimestamp, createdAt, updatedAt))
                            
                            mydb.commit()
                            mycursor.close()

                            


                        if message.find('settingsUpdated') != -1:
                            data = json.loads(message[message.find('{'):message.rfind('}')+1])
                            allTimeNumBets = data['globalStats']['allTimeNumBets']
                            mycursor = mydb.cursor()

                            sql = "INSERT INTO totalbets (allTimeNumBets) VALUES (%s)"
                            mycursor.execute(sql, [allTimeNumBets])
                            
                            mydb.commit()
                            mycursor.close()

                        if message.find('new_message') != -1:
                            data = json.loads(message[message.find('{'):message.rfind('}')+1])
                            # print("New message: ", data)

        except websockets.exceptions.ConnectionClosedOK:
            print("WebSocket connection closed with status code 1005 (no status code [internal])")
            # Handle the closure or attempt to reconnect

        except websockets.exceptions.ConnectionClosedError as e:
            print(f"WebSocket connection closed with status code {e.code}: {e.reason}")
            print(e)
            # Handle other specific closure reasons

        except websockets.exceptions.WebSocketException as e:
            print(f"WebSocket exception occurred: {str(e)}")
            # Handle other WebSocket exceptions

        except Exception as e:
            print(f"An error occurred: {str(e)}")
            # Handle other general exceptions

        # Attempt to reconnect after a delay
        await asyncio.sleep(0)

asyncio.get_event_loop().run_until_complete(connect_to_websocket())