# OMMOCAR: Online Mapless Moving Object detection for 3D LiDAR using oCclusion Accumulation in Range image

<p align = "center">
<img src= "https://github.com/JunhaAgu/Mapless_Moving_matlab/blob/main/imgs/thumbnail_white.png" alt="aligned four lidars via the AutoL2LCalib" width="450" height="470">
</p> 

## 1. Descriptions
**Note:** This software is based on our paper (IEEE Transactions on Instrumentation and Measurement):

The **OMMOCAR** is a program to detect moving objects for 3D LiDAR using occlusion accumulation in range image.

The source code is written in two languages: MATLAB and C++.
(This source code is MATLAB ver.)

Four main features of the **OMMOCAR** are like;
- The proposed method **does not require prior information** about objects or maps, and outputs are at the point level.
- By **accumulating occlusion in the range image domain** and using bitwise operations, the computational speed of the proposed method is about 20 Hz or faster, suitable to run in real-time.
- Because the proposed method is **not coupled with a pose estimation module**, it can be used as the front-end of other 3D LiDAR odometry algorithms.

We demonstrate that the proposed method improves the existing 3D LiDAR odometry algorithms' performance with **KITTI odometry** and **synthetic datasets**(CARLA).

*The C++ version of the code is uploaded in [OMMOCAR C++ ver.](https://github.com/JunhaAgu/mapless_dynamic).*

- Maintainers: Junha Kim (wnsgk02@snu.ac.kr) and Changhyeon Kim (rlackd93@snu.ac.kr)

- ### Datasets used in the paper
The datasets used in our submission are **KITTI odometry (with SemanticKITTI)** and synthetic datasets obtained from **CARLA**

We evaluate with *00*, *01*, *02*, *05* and *07* of **KITTI odometry**, and *town01* and *town03* of **CARLA**. 

- KITTI odometry: [KITTI_odometry](https://www.cvlibs.net/datasets/kitti/eval_odometry.php)
- SemanticKITTI: [SemanticKITTI](http://www.semantic-kitti.org/dataset.html#download)
- CARLA: [CARLA](https://carla.org/)

Especially, a dataset (referred as 'four_lidars') is obtained by using four Velodyne VLP-16 LiDARs. All extrinsic relative poses among LiDARs estimated by the proposed algorithm are included in each folder of datasets. 

*The detailed descriptions (data structure, intrinsic parameters, and etc..) can be seen a* **"READ_ME.txt"** *file in the dataset zip file.*

- [Download link](https://larr.snu.ac.kr/drive/d/s/uulKtWN4b41HXBNk92QigruwP2eBMqhY/4-Lw2fCmp5F_xCIgcX2TNC_qzBnMwVFd-HbYgiTNDsQo) (767 Mb)
