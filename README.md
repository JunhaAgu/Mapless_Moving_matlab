# OMMOCAR: Online Mapless Moving Object detection for 3D LiDAR using oCclusion Accumulation in Range image

<img src= "https://github.com/JunhaAgu/Mapless_Moving_matlab/blob/main/imgs/thumbnail_white.png" alt="aligned four lidars via the AutoL2LCalib" width="474" height="465"> <img src= "https://github.com/JunhaAgu/Mapless_Moving_matlab/blob/main/video/KITTI_00.gif" alt="aligned four lidars via the AutoL2LCalib" width="495" height="385">

## 1. Descriptions
**Note:** This software is based on our paper (IEEE Transactions on Instrumentation and Measurement):

The **OMMOCAR** is a program to detect moving objects for 3D LiDAR using occlusion accumulation in range image.

The source code is written in two languages: MATLAB and C++.
(This source code is MATLAB ver.)

*The C++ version of the code is uploaded in [OMMOCAR C++ ver](https://github.com/JunhaAgu/mapless_dynamic).*

Four main features of the **OMMOCAR** are like;
- The proposed method **does not require prior information** about objects or maps, and outputs are at the **point level**.
- By **accumulating occlusion in the range image domain** and using bitwise operations, the computational speed of the proposed method is about 20 Hz or faster, suitable to run in real-time.
- Because the proposed method is **not coupled with a pose estimation module**, it can be used as the front-end of other 3D LiDAR odometry algorithms.

We demonstrate that the proposed method improves the existing 3D LiDAR odometry algorithms' performance with **KITTI odometry** and **synthetic datasets** (CARLA).

- Maintainers: Junha Kim (wnsgk02@snu.ac.kr) and Changhyeon Kim (rlackd93@snu.ac.kr)

### Datasets used in the paper
The datasets used in our submission are **KITTI odometry (with SemanticKITTI)** and **synthetic datasets** obtained from **CARLA**

- KITTI odometry: [KITTI_odometry](https://www.cvlibs.net/datasets/kitti/eval_odometry.php)
- SemanticKITTI: [SemanticKITTI](http://www.semantic-kitti.org/dataset.html#download)
- CARLA: [CARLA](https://carla.org/)

We evaluate with *00*, *01*, *02*, *05* and *07* of **KITTI odometry**, and *town01* and *town03* of **CARLA**. 

- **KITTI** *00*: 4390 - 4530
- **KITTI** *01*: 150  - 250
- **KITTI** *02*: 860  - 950
- **KITTI** *05*: 2350 - 2670
- **KITTI** *07*: 630  - 820
- **CARLA** *town01* &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : 10 - 370
- **CARLA** *town01_001* : 10 - 370
- **CARLA** *town01_002* : 10 - 370
- **CARLA** *town03* &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; : 10 - 400
- **CARLA** *town03_001* : 10 - 400
- **CARLA** *town03_002* : 10 - 400
  
*The subscripts 001 and 002 of the town01 and town03 mean 3D points have zero mean Gaussian noise whose std. is 0.01, 0.02 m.*

Download datasets - [Download link](https://larr.snu.ac.kr/drive/d/s/uulKtWN4b41HXBNk92QigruwP2eBMqhY/4-Lw2fCmp5F_xCIgcX2TNC_qzBnMwVFd-HbYgiTNDsQo)

## 2) How to run OMMOCAR MATLAB ver.?
### (a) Dependencies
Recommend: MATLAB version >= 2021b with Windows 10.

In versions under 2021b, some functions in the code could not be supported. Please notify us if you have problems when using the program.

### (2) Installation
Just download this repository.

### (3) Run
Modify the directory of datasets in **load_Dataset.m** file and run **main.m**.
