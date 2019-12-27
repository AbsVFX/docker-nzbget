# Build Environment
#
# Build the source code using the latest stable version of the Alpine docker image that is known to work with the
# NZBGet Source Code & the packages required to build the source.
FROM alpine:3.11
# Copy the source code from the level of this Dockerfile over to the temporary working directory within the newly
# spawned container
COPY . /tmp/nzbget
# Install the required dependencies to build NZBGet
RUN \
    apk add \
    git \
    gcc \
    g++ \
    libxml2-dev \
    ncurses-dev \
    openssl-dev \
    make
# Change to the working directory that contains the copied source code, and perform the build process
RUN \
    cd /tmp/nzbget && \
    ./configure --prefix=/tmp/nzbget_out/usr && \
    make -j8 && \
    mkdir -p /tmp/nzbget_out/usr && \
    make PREFIX=/tmp/nzbget_out/usr install

# Production Image
#
# Run the NZBGet image from the latest stable version of alpine
FROM alpine:3.11
# Copy the compiled source code from the previous container in to the newly container, without the development
# libraries
COPY --from=0 /tmp/nzbget_out/ /
# Install the required dependencies to run NZBGet
RUN \
    apk add \
    libxml2 \
    ncurses \
    libstdc++
# Expose port 6789 to allow access to the Web interface
EXPOSE 6789
# Set the configuration file for NZBGet as an external volume
VOLUME /etc/nzbget.conf
# Set the entry point to launch the NZBGet binary, pointing to the exposed configuration file
ENTRYPOINT ["/usr/bin/nzbget", "--server", "--configfile", "/etc/nzbget.conf", "-o", "OutputMode=log", "-o", "ConfigTemplate=/usr/share/nzbget/nzbget.conf", "-o", "WebDir=/usr/share/nzbget/webui"]