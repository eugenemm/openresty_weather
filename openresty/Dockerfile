FROM openresty/openresty

# VOLUME ./conf.d /etc/nginx/conf.d

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openresty-opm \
    && opm get leafo/pgmoon


# RUN mkdir -p /opt/openresty && cd /opt/openresty
# RUN apt install -y git
# RUN git clone https://github.com/openresty/lua-resty-redis.git

# RUN mkdir -p /opt/openresty/resty/http
# RUN git clone https://github.com/ledgetech/lua-resty-http /opt/openresty/resty/http

RUN opm get ledgetech/lua-resty-http