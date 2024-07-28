# LSD-SLAM Docker Version
## Based on Ubuntu 18.04 and ROS-Melodic
If you want to install LSD-SLAM directly with Ubuntu 18.04 without docker, please follow the commands in [Dockerfile](Dockerfile) manually.\
Orignal LSD-SLAM README can be found [here](lsd_readme.md).

## Build Docker Image
1. Clone this repository:
```bash
git clone https://github.com/zhangganlin/lsd-slam-docker.git lsd_ws
```
2. Change xhost:
```bash
# Run this command every time you boot
xhost +local:root
```

3. Build the docker image:
```bash
cd lsd_ws
docker build -t lsd-slam .
``` 
4. Install `nvidia-container-toolkit` for GPU support:\
Instruction can be found at: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

## Install LSD-SLAM inside Docker
1. Create a lsd-slam container:
```bash
docker run -it --privileged --name lsd-slam --network host \
    --env NVIDIA_VISIBLE_DEVICES=all \
    --env NVIDIA_DRIVER_CAPABILITIES=all \
    --env DISPLAY=$DISPLAY --env QT_X11_NO_MITSHM=1 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v .:/root/lsd_ws \
    --gpus all  --device /dev/dri:/dev/dri \
    lsd-slam /bin/bash
```

2. Inside the container, install LSD-SLAM:
```bash
cd /root/lsd_ws
catkin_make
```

3. Inside the container, download demo dataset:
```bash
mkdir -p datasets && cd datasets
wget https://vision.in.tum.de/webshare/g/lsd/LSD_room.bag.zip
unzip LSD_room.bag.zip && rm LSD_room.bag.zip
```

## Running LSD-SLAM
1. Restart the container if it has been stopped:
```bash
docker restart lsd-slam
```

2. Run `roscore`:
```bash
docker exec -it  --privileged lsd-slam \
    bash -c "source /opt/ros/melodic/setup.sh && \
             roscore"
```

3. In a new terminal, run lsd-slam:
```bash
docker exec -it  --privileged  lsd-slam \
    bash -c "source /opt/ros/melodic/setup.sh && \
             source /root/lsd_ws/devel/setup.sh && \
             rosrun lsd_slam_core \
                    live_slam image:=/image_raw \
                    camera_info:=/camera_info"
```

4. In a new terminal, run lsd-slam-viewer for visualization:
```bash
docker exec -it  --privileged lsd-slam \
    bash -c "source /opt/ros/melodic/setup.sh && \
             source /root/lsd_ws/devel/setup.sh && \
             rosrun lsd_slam_viewer viewer"
```

5. For testing, try with the example dataset (the corresponding rosbag has been already inside the docker image):
```bash
docker exec -it  --privileged  lsd-slam \
    bash -c "source /opt/ros/melodic/setup.sh && \
             source /root/lsd_ws/devel/setup.sh && \
             rosbag play /root/lsd_ws/datasets/LSD_room.bag"
```

## Docker Tips
In case you are not familiar with docker, here are some basic docker tips.
1. The above commands create a docker container called `lsd-slam`. You can always check the existing containers by 
```bash
docker ps -a
```
2. To restart a existing container (e.g. after exiting, you want to use it again, here we use `lsd-slam` as example), use
```bash
docker restart lsd-slam
```
To use this container to run other commands, use `docker exec` like above.

2. The `-v` parameter can be used to mount a local folder, but this must be done during `docker run`, i.e. when creating the container.
```bash
docker run -it --privileged --name lsd-slam --network host \
    --env NVIDIA_VISIBLE_DEVICES=all \
    --env NVIDIA_DRIVER_CAPABILITIES=all \
    --env DISPLAY=$DISPLAY --env QT_X11_NO_MITSHM=1 \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v [LOCAL_FOLDER]:[PATH_INSIDE_CONTAINER] \
    --gpus all  --device /dev/dri:/dev/dri \
    lsd-slam /bin/bash
```

3. Remove existing container, first make sure it has been stopped
```bash
docker stop lsd-slam
```
And then, remove it
```bash
docker rm lsd-slam
```
Notice that removing a container would NOT remove the corresponding docker image, i.e. if you want to use the image again, just create another container, which would not take much time since we have already built the docker image.

4. Remove docker image. This would delete the environment completely.
```
docker rmi lsd-slam
```
