FROM cloudprober/cloudprober as cloudprober

FROM alpine:3.7

COPY --from=cloudprober /cloudprober /cloudprober
COPY --from=cloudprober /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY cloudprober.cfg /etc/

