# Start from Alpine Linux Edge
FROM alpine:edge

## Variables
# Define APK packages to be installed for compiling tcpdump
ENV APK_DEPS gcc libpcap-dev libcrypto1.1 make musl musl-dev perl libcap-ng-dev libcap-dev grpc-dev libsmi openssl-dev

## Dependencies
# Install APK dependencies
RUN apk add $APK_DEPS

## Staging
# Copy the contents of the directory this file is in to /opt/tcpdump inside the container
ADD . /opt/tcpdump

## Compiling
# Run ./configure
RUN cd /opt/tcpdump && ./configure

# Make all the things
RUN cd /opt/tcpdump && make -j $(nproc) all

# Run make check to ensure everything is OK 
# (container build will fail if this check fails, therefore preventing known failing binaries from making it into production containers)
RUN cd /opt/tcpdump && make -j $(nproc) check

## Installing
# Install tcpdump
RUN cd /opt/tcpdump && make -j $(nproc) install

## Cleaning up
# Remove the directory we just used for building tcpdump
RUN rm -rf /opt/tcpdump

# Remove APK packages from earlier
RUN apk del --purge $APK_DEPS

# Set entrypoint to where tcpdump was automatically installed to
ENTRYPOINT ["/usr/local/bin/tcpdump"]
