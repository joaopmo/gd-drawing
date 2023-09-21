import json
import argparse
import asyncio
import websockets
import numpy as np
import cv2
from PIL import Image
from transformers import TrOCRProcessor, VisionEncoderDecoderModel

padding = 20


async def process(message, ws):
    event = json.loads(message)

    if event["type"] == "char":
        [x_min, y_min, x_max, y_max] = event["bbox"]
        width = x_max - x_min + 1
        height = y_max - y_min + 1
        array = np.full([height + padding, width + padding], 255, dtype=np.uint8)

        pad = padding // 2
        for line in event["data"]:
            if len(line) >= 2:
                line = np.array([[x - x_min + pad, y - y_min + pad] for [x, y] in line]).reshape((-1, 1, 2))
                array = cv2.polylines(array, [line], False, (0, 0, 0), 2)
            elif len(line) == 1:
                [x, y] = line[0]
                array = cv2.circle(array, [x - x_min + pad, y - y_min + pad], 2, (0, 0, 0), 2)

        img = Image.fromarray(array).convert("RGB")

        processor = TrOCRProcessor.from_pretrained('microsoft/trocr-base-handwritten')
        model = VisionEncoderDecoderModel.from_pretrained('microsoft/trocr-base-handwritten')
        pixel_values = processor(images=img, return_tensors="pt").pixel_values
        generated_ids = model.generate(pixel_values)
        generated_text = processor.batch_decode(generated_ids, skip_special_tokens=True)[0]

        await ws.send(generated_text)
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
