# RDMA tcpdump

```sh
# build the docker container with all dependencies
make
# enter the docker container
make run
# find the infiniband device
./tcpdump -D | grep mlx
# capture network traffic on the device
./tcpdump -ni mlx5_0
```
