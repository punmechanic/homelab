FROM alpine
RUN apk add wget
RUN wget https://github.com/opentofu/opentofu/releases/download/v1.7.0/tofu_1.7.0_386.apk
RUN apk add --allow-untrusted tofu_1.7.0_386.apk
RUN adduser -S tofu
USER tofu
WORKDIR /home/tofu
VOLUME /sources
ENTRYPOINT ["tofu", "-chdir=/sources/", "apply"]
