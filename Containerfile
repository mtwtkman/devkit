FROM archlinux:latest

ARG USER_ID
ARG USER_NAME
ARG GROUP_ID
ARG GROUP_NAME
ARG APP_DIR
ARG SHELL
RUN yes | pacman -Sy unzip sudo
RUN groupadd --gid $GROUP_ID $GROUP_NAME
RUN useradd \
  --gid $GROUP_ID \
  --shell $SHELL \
  --uid $USER_ID \
  --create-home \
  $USER_NAME
RUN echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers
RUN su $USER_NAME -
RUN mkdir -p $APP_DIR
RUN chown $USER_NAME:$GROUP_NAME $APP_DIR
WORKDIR $APP_DIR
