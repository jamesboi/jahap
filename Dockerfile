FROM haproxy:1.5
ENV SS_IP1 0.0.0.0
ENV SS_IP2 0.0.0.0
ENV SS_IP3 0.0.0.0
ENV SS_IP4 0.0.0.0
EXPOSE 8000
EXPOSE 7000
EXPOSE 6000
EXPOSE 5000
ADD haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
RUN cat /usr/local/etc/haproxy/haproxy.cfg
