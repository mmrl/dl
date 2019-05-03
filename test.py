from tensorflow.python.client import device_lib
from keras import backend as K

print(device_lib.list_local_devices())
# sess = tf.Session(config=tf.ConfigProto(log_device_placement=True))

K.tensorflow_backend._get_available_gpus()
