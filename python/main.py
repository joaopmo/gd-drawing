import json
import argparse
import asyncio
import websockets
import numpy as np
import cv2
from PIL import Image
from transformers import TrOCRProcessor, VisionEncoderDecoderModel

margin = 20


async def process(message, ws):
    event = json.loads(message)

    if event["type"] == "char":
        bbox = event["bbox"]
        width = bbox[2] - bbox[0] + 1
        height = bbox[3] - bbox[1] + 1
        array = np.full([height + margin, width + margin], 255, dtype=np.uint8)
        m = margin // 2
        for line in event["data"]:
            if len(line) >= 2:
                line = np.array([[x - bbox[0] + m, y - bbox[1] + m] for [x, y] in line]).reshape((-1, 1, 2))
                array = cv2.polylines(array, [line], False, (0, 0, 0), 2)
            elif len(line) == 1:
                [x, y] = line[0]
                array = cv2.circle(array, [x - bbox[0] + m, y - bbox[1] + m], 2, (0, 0, 0), 2)

        img = Image.fromarray(array).convert("RGB")

        processor = TrOCRProcessor.from_pretrained('microsoft/trocr-base-handwritten')
        model = VisionEncoderDecoderModel.from_pretrained('microsoft/trocr-base-handwritten')
        pixel_values = processor(images=img, return_tensors="pt").pixel_values
        generated_ids = model.generate(pixel_values)
        generated_text = processor.batch_decode(generated_ids, skip_special_tokens=True)

        await ws.send(json.dumps(generated_text))
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
