FROM ubuntu:22.04

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:rootpassword' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's@session\s*required\s*pam_limits.so@session required pam_limits.so@g' /etc/pam.d/sshd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
