pwd=
sudo rm -r /home/project12321
sudo mkdir /home/project12321
cd /home/project12321
sudo git clone https://github.com/ultralytics/yolov5.git
cd -
sudo cp test_run.ipynb /home/project12321/yolov5
sudo cp test.png /home/project12321/yolov5
sudo cp best.pt /home/project12321/yolov5
cd -
cd yolov5
sudo mkdir -p runs/train/exp9
sudo cp ./best.pt /home/project12321/yolov5/runs/train/exp9
jupyter-notebook
