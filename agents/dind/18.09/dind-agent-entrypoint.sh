#!/bin/sh
# Optional environment variables :
# * DOCKER_OPTS : Docker options to add to the docker daemon

set -e

_tls_ensure_private() {
	local f="$1"; shift
	[ -s "$f" ] || openssl genrsa -out "$f" 4196
}
_tls_san() {
	{
		ip -oneline address | awk '{ gsub(/\/.+$/, "", $4); print "IP:" $4 }'
		{
			cat /etc/hostname
			echo 'docker'
			echo 'localhost'
			hostname -f
			hostname -s
		} | sed 's/^/DNS:/'
		[ -z "${DOCKER_TLS_SAN:-}" ] || echo "$DOCKER_TLS_SAN"
	} | sort -u | xargs printf '%s,' | sed "s/,\$//"
}
_tls_generate_certs() {
	local dir="$1"; shift

	# if ca/key.pem || !ca/cert.pem, generate CA public if necessary
	# if ca/key.pem, generate server public
	# if ca/key.pem, generate client public
	# (regenerating public certs every startup to account for SAN/IP changes and/or expiration)

	# https://github.com/FiloSottile/mkcert/issues/174
	local certValidDays='825'

	if [ -s "$dir/ca/key.pem" ] || [ ! -s "$dir/ca/cert.pem" ]; then
		# if we either have a CA private key or do *not* have a CA public key, then we should create/manage the CA
		mkdir -p "$dir/ca"
		_tls_ensure_private "$dir/ca/key.pem"
		openssl req -new -key "$dir/ca/key.pem" \
			-out "$dir/ca/cert.pem" \
			-subj '/CN=docker:dind CA' -x509 -days "$certValidDays"
	fi

	if [ -s "$dir/ca/key.pem" ]; then
		# if we have a CA private key, we should create/manage a server key
		mkdir -p "$dir/server"
		_tls_ensure_private "$dir/server/key.pem"
		openssl req -new -key "$dir/server/key.pem" \
			-out "$dir/server/csr.pem" \
			-subj '/CN=docker:dind server'
		cat > "$dir/server/openssl.cnf" <<-EOF
			[ x509_exts ]
			subjectAltName = $(_tls_san)
		EOF
		openssl x509 -req \
				-in "$dir/server/csr.pem" \
				-CA "$dir/ca/cert.pem" \
				-CAkey "$dir/ca/key.pem" \
				-CAcreateserial \
				-out "$dir/server/cert.pem" \
				-days "$certValidDays" \
				-extfile "$dir/server/openssl.cnf" \
				-extensions x509_exts
		cp "$dir/ca/cert.pem" "$dir/server/ca.pem"
		openssl verify -CAfile "$dir/server/ca.pem" "$dir/server/cert.pem"
	fi

	if [ -s "$dir/ca/key.pem" ]; then
		# if we have a CA private key, we should create/manage a client key
		mkdir -p "$dir/client"
		_tls_ensure_private "$dir/client/key.pem"
		chmod 0644 "$dir/client/key.pem" # openssl defaults to 0600 for the private key, but this one needs to be shared with arbitrary client contexts
		openssl req -new \
				-key "$dir/client/key.pem" \
				-out "$dir/client/csr.pem" \
				-subj '/CN=docker:dind client'
		cat > "$dir/client/openssl.cnf" <<-'EOF'
			[ x509_exts ]
			extendedKeyUsage = clientAuth
		EOF
		openssl x509 -req \
				-in "$dir/client/csr.pem" \
				-CA "$dir/ca/cert.pem" \
				-CAkey "$dir/ca/key.pem" \
				-CAcreateserial \
				-out "$dir/client/cert.pem" \
				-days "$certValidDays" \
				-extfile "$dir/client/openssl.cnf" \
				-extensions x509_exts
		cp "$dir/ca/cert.pem" "$dir/client/ca.pem"
		openssl verify -CAfile "$dir/client/ca.pem" "$dir/client/cert.pem"
	fi
}

# set "dockerSocket" to the default "--host" *unix socket* value (for both standard or rootless)
uid="$(id -u)"
if [ "$uid" = '0' ]; then
	dockerSocket='unix:///var/run/docker.sock'
else
	# if we're not root, we must be trying to run rootless
	: "${XDG_RUNTIME_DIR:=/run/user/$uid}"
	dockerSocket="unix://$XDG_RUNTIME_DIR/docker.sock"
fi
case "${DOCKER_HOST:-}" in
	unix://*)
		dockerSocket="$DOCKER_HOST"
		;;
esac

# add our default arguments
if [ -n "${DOCKER_TLS_CERTDIR:-}" ] \
	&& _tls_generate_certs "$DOCKER_TLS_CERTDIR" \
	&& [ -s "$DOCKER_TLS_CERTDIR/server/ca.pem" ] \
	&& [ -s "$DOCKER_TLS_CERTDIR/server/cert.pem" ] \
	&& [ -s "$DOCKER_TLS_CERTDIR/server/key.pem" ] \
; then
    if [ "$#" -eq 0 ]; then
        # See https://github.com/docker-library/docker/blob/master/18.09/dind/dockerd-entrypoint.sh
        set -- dockerd \
            --host="$dockerSocket" \
            --host=tcp://0.0.0.0:2376 \
            --tlsverify \
            --tlscacert "$DOCKER_TLS_CERTDIR/server/ca.pem" \
            --tlscert "$DOCKER_TLS_CERTDIR/server/cert.pem" \
            --tlskey "$DOCKER_TLS_CERTDIR/server/key.pem" \
            "$DOCKER_OPTS"
    else 
      echo "Starting the Docker daemon..."
      sh "$(which dind)" dockerd \
          --host="$dockerSocket" \
          --host=tcp://0.0.0.0:2376 \
          --tlsverify \
          --tlscacert "$DOCKER_TLS_CERTDIR/server/ca.pem" \
          --tlscert "$DOCKER_TLS_CERTDIR/server/cert.pem" \
          --tlskey "$DOCKER_TLS_CERTDIR/server/key.pem" \
          $DOCKER_OPTS &
      
      while(! docker info > /dev/null 2>&1); do
          echo "Waiting for the Docker daemon to start..."
          sleep 1
      done
      
      echo "Docker Daemon started"
    fi
else
    # TLS disabled (-e DOCKER_TLS_CERTDIR='') or missing certs
    if [ "$#" -eq 0 ]; then
        # See https://github.com/docker-library/docker/blob/master/18.09/dind/dockerd-entrypoint.sh
        set -- dockerd \
            --host="$dockerSocket" \
            --host=tcp://0.0.0.0:2375 \
            "$DOCKER_OPTS"
    else 
      echo "Starting the Docker daemon..."
      sh "$(which dind)" dockerd \
          --host="$dockerSocket" \
          --host=tcp://0.0.0.0:2375 \
          $DOCKER_OPTS &
      
      while(! docker info > /dev/null 2>&1); do
          echo "Waiting for the Docker daemon to start..."
          sleep 1
      done
      
      echo "Docker Daemon started"
    fi
fi

exec "$@"