FROM teddysun/v2ray

# 1) v2ray config (သင့် config.json ကို repo root ထဲမှာ ထားပြီး copy ထည့်ပါ)
COPY config.json /etc/v2ray/config.json

# 2) Alpine packages
RUN apk add --no-cache nginx gettext

# 3) Default nginx html ဖယ်ပြီး မင်းရဲ့ UI ထည့်
RUN rm -f /usr/share/nginx/html/*
COPY index.html /usr/share/nginx/html/index.html

# 4) nginx.conf template + entrypoint
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 5) Cloud Run env
ENV PORT=8080
ENV V2RAY_PORT=10000

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]