changing dockerfs to systemd
Configure docker
After you install and start docker, by default it will use cgroupfs as the cgroup driver, check by running:

docker info | grep Cgroup

Cgroup Driver: cgroupfs
Edit /usr/lib/systemd/system/docker.service file:

ExecStart=/usr/bin/dockerd --exec-opt native.cgroupdriver=systemd
Then reload daemon and restart docker

systemctl daemon-reload
systemctl restart docker

