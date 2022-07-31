
https://github.com/ManuelEV/openpose-docker-deploy

cd ./openpose-docker-deploy

sudo docker build -t openpose


docker run --gpus all -e NVIDIA_VISIBLE_DEVICES=0 --name openpose -it openpose /bin/bash

gunicorn --bind 0.0.0.0:5000 wsgi:app