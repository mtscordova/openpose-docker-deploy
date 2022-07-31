
https://github.com/ManuelEV/openpose-docker-deploy

cd ./openpose-docker-deploy

sudo docker build -t openpose

sudo docker run --gpus all --name openpose -it openpose /bin/bash
