FROM python:3.9-slim

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-client \
    vim less \
    && rm -rf /var/lib/apt/lists/* \
    && adduser ansible --gecos "" --disabled-password --home /ansible --quiet

# Install Ansible
RUN pip install ansible

USER ansible

# Create working directory
WORKDIR /ansible

# Set environment variables
ENV ANSIBLE_HOST_KEY_CHECKING=False
