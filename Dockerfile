FROM tomcat:9.0.82-jdk8-corretto-al2

2
ARG version=1.8.0_392.b08-1

0 B
3
|1 version=1.8.0_392.b08-1 /bin/sh -c set -eux && export GNUPGHOME="$(mktemp -d)" && curl -fL -o corretto.key https://yum.corretto.aws/corretto.key && gpg --batch --import corretto.key && gpg --batch --export --armor '6DC3636DAE534049C8B94623A122542AB04F24E3' > corretto.key && rpm --import corretto.key && rm -r "$GNUPGHOME" corretto.key && curl -fL -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo && grep -q '^gpgcheck=1' /etc/yum.repos.d/corretto.repo && echo "priority=9" >> /etc/yum.repos.d/corretto.repo && yum install -y java-1.8.0-amazon-corretto-devel-$version && (find /usr/lib/jvm/java-1.8.0-amazon-corretto -name src.zip -delete || true) && yum install -y fontconfig && yum clean all

75.59 MB
4
ENV LANG=C.UTF-8

0 B
5
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto

0 B
6
ENV CATALINA_HOME=/usr/local/tomcat

0 B
7
ENV PATH=/usr/local/tomcat/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

0 B
8
/bin/sh -c mkdir -p "$CATALINA_HOME"

171 B
9
WORKDIR /usr/local/tomcat

0 B
10
ENV TOMCAT_NATIVE_LIBDIR=/usr/local/tomcat/native-jni-lib

0 B
11
ENV LD_LIBRARY_PATH=/usr/local/tomcat/native-jni-lib

0 B
12
ENV GPG_KEYS=48F8E69F6390C9F25CFEDCD268248959359E722B A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 DCFD35E0BF8CA7344752DE8B6FB21E8933C60243

0 B
13
ENV TOMCAT_MAJOR=9

0 B
14
ENV TOMCAT_VERSION=9.0.82

0 B
15
ENV TOMCAT_SHA512=2b13f11f4e0d0b9aee667c256c6ea5d2853b067e8b7e8293f117da050d3833fda8aa9d9ad278bd12fb7fbf0825108c7d0384509f44c05f9bad73eb099cfaa128

0 B
16
/bin/sh -c set -eux; if ! command -v yumdb > /dev/null; then yum install -y --setopt=skip_missing_names_on_install=False yum-utils; yumdb set reason dep yum-utils; fi; _yum_install_temporary() { ( set -eu +x; local pkg todo=''; for pkg; do if ! rpm --query "$pkg" > /dev/null 2>&1; then todo="$todo $pkg"; fi; done; if [ -n "$todo" ]; then set -x; yum install -y --setopt=skip_missing_names_on_install=False $todo; yumdb set reason dep $todo; fi; ) }; _yum_install_temporary gzip tar; ddist() { local f="$1"; shift; local distFile="$1"; shift; local mvnFile="${1:-}"; local success=; local distUrl=; for distUrl in "https://www.apache.org/dyn/closer.cgi?action=download&filename=$distFile" "https://downloads.apache.org/$distFile" "https://www-us.apache.org/dist/$distFile" "https://www.apache.org/dist/$distFile" "https://archive.apache.org/dist/$distFile" ${mvnFile:+"https://repo1.maven.org/maven2/org/apache/tomcat/tomcat/$mvnFile"} ; do if curl -fL -o "$f" "$distUrl" && [ -s "$f" ]; then success=1; break; fi; done; [ -n "$success" ]; }; ddist 'tomcat.tar.gz' "tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz" "$TOMCAT_VERSION/tomcat-$TOMCAT_VERSION.tar.gz"; echo "$TOMCAT_SHA512 *tomcat.tar.gz" | sha512sum --strict --check -; ddist 'tomcat.tar.gz.asc' "tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz.asc" "$TOMCAT_VERSION/tomcat-$TOMCAT_VERSION.tar.gz.asc"; export GNUPGHOME="$(mktemp -d)"; for key in $GPG_KEYS; do gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; done; gpg --batch --verify tomcat.tar.gz.asc tomcat.tar.gz; tar -xf tomcat.tar.gz --strip-components=1; rm bin/*.bat; rm tomcat.tar.gz*; rm -rf "$GNUPGHOME"; mv webapps webapps.dist; mkdir webapps; nativeBuildDir="$(mktemp -d)"; tar -xf bin/tomcat-native.tar.gz -C "$nativeBuildDir" --strip-components=1; _yum_install_temporary apr-devel gcc make openssl11-devel ; ( export CATALINA_HOME="$PWD"; cd "$nativeBuildDir/native"; aprConfig="$(command -v apr-1-config)"; ./configure --libdir="$TOMCAT_NATIVE_LIBDIR" --prefix="$CATALINA_HOME" --with-apr="$aprConfig" --with-java-home="$JAVA_HOME" --with-ssl ; nproc="$(nproc)"; make -j "$nproc"; make install; ); rm -rf "$nativeBuildDir"; rm bin/tomcat-native.tar.gz; find "$TOMCAT_NATIVE_LIBDIR" -type f -executable -exec ldd '{}' ';' | awk '/=>/ && $(NF-1) != "=>" { print $(NF-1) }' | xargs -rt readlink -e | sort -u | xargs -rt rpm --query --whatprovides | sort -u | tee "$TOMCAT_NATIVE_LIBDIR/.dependencies.txt" | xargs -r yumdb set reason user ; yum autoremove -y; yum clean all; rm -rf /var/cache/yum; find ./bin/ -name '*.sh' -exec sed -ri 's|^#!/bin/sh$|#!/usr/bin/env bash|' '{}' +; chmod -R +rX .; chmod 1777 logs temp work; catalina.sh version

16.88 MB
17
/bin/sh -c set -eux; nativeLines="$(catalina.sh configtest 2>&1)"; nativeLines="$(echo "$nativeLines" | grep 'Apache Tomcat Native')"; nativeLines="$(echo "$nativeLines" | sort -u)"; if ! echo "$nativeLines" | grep -E 'INFO: Loaded( APR based)? Apache Tomcat Native library' >&2; then echo >&2 "$nativeLines"; exit 1; fi

131 B
18
EXPOSE 8080

0 B
19
CMD ["catalina.sh" "run"]

