FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    shellinabox \
    sudo \
    openssh-server \
    bash

# Copy scripts
COPY setup_user.sh /setup_user.sh
COPY setup_challenges.sh /setup_challenges.sh


# Make executable
RUN chmod +x /setup_user.sh /setup_challenges.sh 



EXPOSE 4200
CMD ["/usr/bin/shellinaboxd", "-p", "4200", "--no-beep", "--disable-ssl"]
