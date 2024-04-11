from fastapi import FastAPI, UploadFile, File
from PIL import Image
import io
import numpy as np
from keras.applications.vgg16 import VGG16
from sklearn.metrics.pairwise import cosine_similarity
from keras.preprocessing import image
from ultralytics import YOLO
import uvicorn

app = FastAPI()


vgg16 = VGG16(weights='imagenet', include_top=False, pooling='max', input_shape=(224, 224, 3))

for model_layer in vgg16.layers:
    model_layer.trainable = False

def get_image_embeddings(object_image: image):
    image_array = np.expand_dims(image.img_to_array(object_image), axis=0)
    image_embedding = vgg16.predict(image_array)
    return image_embedding


@app.get("/")
def root():
    return {"message": "Hello World", "var": 1234}

@app.post("/get_similarity_score")
async def get_similarity_score(image1: UploadFile = File(...), image2: UploadFile = File(...)):
    content1 = await image1.read()
    content2 = await image2.read()

    f1 = io.BytesIO(content1)
    f2 = io.BytesIO(content2)

    im1 = Image.open(f1).resize((224, 224))
    im2 = Image.open(f2).resize((224, 224))

    input_im1 = get_image_embeddings(im1)
    input_im2 = get_image_embeddings(im2)

    result = cosine_similarity(input_im1, input_im2).reshape(1, )

    return {float(result[0])}



# Initialize the YOLO model
yolo_model = YOLO('yolov8n.pt')
custom_model = YOLO('yolov8n.pt')
custom_model = YOLO('customYolo.pt')

@app.post("/get_detected")
async def get_detected(image: UploadFile = File(...)):
    content = await image.read()
    
    image_stream = io.BytesIO(content)
    input_image = Image.open(image_stream)

    custom_result = custom_model(input_image, conf=0.7)
    custom_detection_results = process_results(custom_result)
    
    if custom_detection_results:
        return custom_detection_results[0][0]
    
    include_class = [24, 25, 26, 27, 32, 36, 38, 39, 41, 45, 63, 64, 65, 66, 67, 73, 76, 77]
    yolo_result = yolo_model(input_image, conf=0.7, classes = include_class)
    yolo_detection_results = process_results(yolo_result)

    if yolo_detection_results:
        return yolo_detection_results[0][0]
    
    return "none"

def process_results(result):
    detection_results = []
    for r in result:
        for c in r.boxes.cls:
            detection_results.append((r.names[int(c)], c))
    
    detection_results.sort(key=lambda x: x[1], reverse=True)
    return detection_results


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
