FROM ubuntu:18.04

RUN apt update
RUN echo 'tzdata tzdata/Areas select Europe' | debconf-set-selections
RUN echo 'tzdata tzdata/Zones/Europe select Zurich' | debconf-set-selections
ENV DEBIAN_FRONTEND=noninteractive 
RUN apt install -y tzdata
RUN apt install -y wget cmake build-essential

RUN wget https://gitlab.com/libeigen/eigen/-/archive/3.2.5/eigen-3.2.5.tar.gz && \
    tar -xzvf eigen-3.2.5.tar.gz && \
    cd eigen-3.2.5 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make install && \
    cd ../.. && \
    rm -rf eigen-3.2.5 eigen-3.2.5.tar.gz

RUN apt install -y gnupg2 curl lsb-core python-pip
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt update

RUN apt install -y ros-melodic-desktop-full

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool
RUN rosdep init
RUN rosdep update
RUN apt install -y python-catkin-tools software-properties-common

#---------------------------------------- above is ros-melodic --------------------------------------------------------------


#---------------------------------------- following is lsd-slam --------------------------------------------------------------
# FROM zhangganlin/ros:melodic

RUN apt install -y ros-melodic-libg2o ros-melodic-cv-bridge liblapack-dev libblas-dev freeglut3-dev libsuitesparse-dev libx11-dev
RUN apt install -y libqglviewer-dev-qt4

RUN cd /usr/lib/x86_64-linux-gnu && ln -s libQGLViewer-qt4.so libQGLViewer.so

# RUN cd /root && git clone https://github.com/zhangganlin/lsd-slam-docker.git lsd_ws
# RUN bash -c "source /opt/ros/melodic/setup.sh && cd /root/lsd_ws && catkin_make"

RUN apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /root/lsd_ws
CMD ["bash"]