# Barbell Detection Models

Place custom TFLite models here for on-device barbell detection.

## Default Behaviour

The app uses Google ML Kit's built-in object detection model by default (no file needed here).
A custom barbell-specific model can be dropped in as `barbell_detector.tflite` to improve accuracy.

## Training a Custom Model

1. Collect ~500+ images of barbells in various lighting/angles
2. Label with bounding boxes around the barbell/plates
3. Fine-tune EfficientDet-Lite0 via TensorFlow Model Maker:
   ```python
   import tflite_model_maker
   from tflite_model_maker.object_detection import DataLoader, EfficientDetLite0Spec
   data = DataLoader.from_pascal_voc('barbell_dataset/')
   model = object_detector.create(data, model_spec=EfficientDetLite0Spec())
   model.export(export_dir='.', tflite_filename='barbell_detector.tflite')
   ```
4. Copy `barbell_detector.tflite` and `barbell_labels.txt` here

## Labels (barbell_labels.txt)

```
barbell
plate
collar
```
