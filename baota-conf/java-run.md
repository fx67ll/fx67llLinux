### java项目启动命令

```shell
/usr/local/btjdk/jdk8/bin/java -Dcom.sun.management.jmxremote.port=8387 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=127.0.0.1 -jar -Xmx1024M -Xms256M  /home/ruoyi/ruoyi-admin.jar --server.port=9897
```

```shell
/usr/bin/java \
-Xms128M -Xmx512M \
-XX:MetaspaceSize=64M -XX:MaxMetaspaceSize=128M \
-XX:MaxDirectMemorySize=128M \
-XX:+UseG1GC -XX:MaxGCPauseMillis=200 \
-Dlogging.pattern.console="%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n" \
-Dlogging.file.max-size=100MB -Dlogging.file.max-history=7 \
-jar /home/ruoyi-chaoshen/ruoyi-admin-chaoshen.jar \
--server.port=9797 \
--spring.boot.admin.enabled=false \
--management.endpoints.web.exposure.include= \
--spring.cache.type=none \
--ruoyi.log.desensitize=false
```