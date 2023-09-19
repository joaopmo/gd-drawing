import argparse
import asyncio
import websockets


async def main(parsed_args):
    uri = f"ws://localhost:{parsed_args.port}"
    async with websockets.connect(uri) as websocket:
        data = await websocket.recv()
        print(f"{data}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Command Line Args')
    parser.add_argument('port')
    args = parser.parse_args()
    asyncio.run(main(args))
