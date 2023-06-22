import asyncio
import websockets

async def send_message(websocket):
    while True:
        print("Sending message")
        await websocket.send("2")
        await asyncio.sleep(25)

async def connect_to_websocket():
    while True:
        try:
            async with websockets.connect('wss://api.roobet.party/socket.io/?EIO=3&transport=websocket') as websocket:
                # Start the send_message coroutine in the background
                asyncio.create_task(send_message(websocket))

                while True:
                    message = await websocket.recv()
                    # Process the received message
                    print(message)
                    # print(".", end='', flush=True)

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