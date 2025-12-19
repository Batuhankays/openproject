# OpenProject Enterprise Edition Patch
# Bu Dockerfile enterprise özellikleri aktive eder

FROM openproject/openproject:14

# Patch dosyasini kopyala
COPY enterprise_token.rb /app/app/models/enterprise_token.rb

# Dosya izinlerini ayarla
RUN chown -R  app:app /app/app/models/enterprise_token.rb

# Önemli: Bu patch unofficial bir yöntemdir
# OpenProject'in Terms of Service'ini incelemenizi öneririz
