
<img src="./appicon.png"  height="400" width="400">
# Plant Pathology Recognition

### 简介
项目内容源自[Kaggle Plant Pathology 2020 - FGVC7](https://www.kaggle.com/c/plant-pathology-2020-fgvc7) 
目的是根据苹果树叶识别出苹果树的健康状态。共有四个状态分别为Health, MultiDiseases, Rust, Scab

### 模型训练
使用华为诺亚方舟CVPR2020中的GhostNet。一种用于构建高效的神经网络结构的新型Ghost模块。Ghost模块将原始卷积层分为两部分，首先使用较少的卷积核来生成原始特征图，然后，进一步使用廉价变换操作以高效生产更多幻影特征图能够将原始模型转换为更紧凑的模型，同时保持可比的性能。
采用GhostNet在ImageNet上预训练的参数，修改classifier部分进行迁移学习。
### 模型部署
Pytorch -> onnx -> onnx-sim 
```
pip install onnx-sim
python3 -m onnx-sim origin.onnx model-sim.onnx
```
修改输入从MLMultiArray为Image，便于后续模型输入处理
```
model_coreml = convert(model="./correctX.onnx")
spec = model_coreml.get_spec()
input = spec.description.input[0]
input.type.imageType.colorSpace = ft.ImageFeatureType.RGB
input.type.imageType.height = 512
input.type.imageType.width = 512
```
### 模型量化
进行三个级别量化：fp16, int8, int4
模型中 fn + bn 的结构无法融合在int量化时会失败。
采用conv 1*1 加载层参数替代 fc 层

### iOS上机运行测试
<img src="./screen_shot.png"  height="1334" width="750">

|Model|Size|Accurary|Average-run-time|
|:-:|:-:|:-:|:-:|
|ResNet18 float32|45.7MB| 0.964| 81.4ms|
|GhostNet float32|15.7MB| 0.957|76.1ms|
|GhostNet float16|7.9MB | 0.957|82.9ms|
|GhostNet int8   |4.0MB | 0.952|113.3ms|
|GhostNet int4   |2.1MB | 0.829|121.2ms|
> Device : iPhone 7
> Platform : iOS 13.0
