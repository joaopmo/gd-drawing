import json
import argparse
import asyncio
import websockets
import numpy as np
import cv2
from PIL import Image


async def process(message, ws):
    event = json.loads(message)

    if event["type"] == "char":
        bbox = event["bbox"]
        width = (bbox[2] - bbox[0]) + 1
        height = (bbox[3] - bbox[1]) + 1
        array = np.zeros([height, width], dtype=np.uint8)

        for line in event["data"]:
            if len(line) >= 2:
                line = np.array([[x - bbox[0], y - bbox[1]] for [x, y] in line]).reshape((-1, 1, 2))
                array = cv2.polylines(array, [line], False, (255, 255, 255), 2)
            elif len(line) == 1:
                array = cv2.circle(array, line[0], 2, (255, 255, 255), 2)

        img = Image.fromarray(array)
        img.save('test.png')




async def main(parsed_args):
    uri = f"ws://localhost:{parsed_args.port}"
    async with websockets.connect(uri) as websocket:
        try:
            async for message in websocket:
                await process(message, websocket)
        except websockets.ConnectionClosed:
            return


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Command Line Args')
    parser.add_argument('port')
    args = parser.parse_args()
    asyncio.run(main(args))
