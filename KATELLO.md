# Katello Installer

A set of tools to properly configure Katello with Foreman in production and development.

## Production Usage

```
$ yum install -y foreman-installer-katello

# install Katello with Foreman and smart proxy with Puppet and Puppetca
$ foreman-installer --scenario katello
```

### Production Examples

```
# Install also provisioning-related services

foreman-installer --scenario                     "katello"\
                  --foreman-proxy-dns            "true"\
                  --foreman-proxy-dns-forwarders "8.8.8.8"\
                  --foreman-proxy-dns-forwarders "8.8.4.4"\
                  --foreman-proxy-dns-interface  "virbr1"\
                  --foreman-proxy-dns-zone       "example.com"\
                  --foreman-proxy-dhcp           "true"\
                  --foreman-proxy-dhcp-interface "virbr1"\
                  --foreman-proxy-tftp           "true"\
                  --foreman-proxy-content-puppet "true"\
                  --foreman-proxy-puppetca       "true"

# Install only DNS with smart proxy

foreman-installer --scenario                     "katello"\
                  --foreman-proxy-dns            "true"\
                  --foreman-proxy-dns-forwarders "8.8.8.8"
                  --foreman-proxy-dns-forwarders "8.8.4.4"\
                  --foreman-proxy-dns-interface  "virbr1"\
                  --foreman-proxy-dns-zone       "example.com"\
                  --foreman-proxy-content-puppet "false"\
                  --foreman-proxy-puppetca       "false"

# Generate certificates for installing Foreman proxy on another system
foreman-proxy-certs-generate --foreman-proxy-fqdn "myforeman-proxy-content.example.com"\
                                     --certs-tar    ~/myforeman-proxy-content.example.com-certs.tar

# Copy the ~/myforeman-proxy.example.com-certs.tar to the foreman-proxy system
# register the system to Katello and run:
foreman-installer --scenario                                "foreman-proxy-content"\
                  --foreman-proxy-register-in-foreman       "true"\
                  --foreman-proxy-foreman-base-url          "https://master.example.com"\
                  --foreman-proxy-trusted-hosts             "master.example.com"\
                  --foreman-proxy-trusted-hosts             "myforeman-proxy.example.com"\
                  --foreman-proxy-oauth-consumer-key        "foreman_oauth_key"\
                  --foreman-proxy-oauth-consumer-secret     "foreman_oauth_secret"\
                  --foreman-proxy-content-pulp-oauth-secret "pulp_oauth_secret"\
                  --foreman-proxy-content-certs-tar         "/root/myforeman-proxy-content.example.com-certs.tar"\
                  --foreman-proxy-content-puppet            "true"\
                  --foreman-proxy-puppetca                  "true"\
                  --foreman-proxy-dns                       "true"\
                  --foreman-proxy-dns-forwarders            "8.8.8.8"\
                  --foreman-proxy-dns-forwarders            "8.8.4.4"\
                  --foreman-proxy-dns-interface             "virbr1"\
                  --foreman-proxy-dns-zone                  "example.com"\
                  --foreman-proxy-dhcp                      "true"\
                  --foreman-proxy-dhcp-interface            "virbr1"\
                  --foreman-proxy-tftp                      "true"
```

## Data Reset

If you run into an error during the initial installation or wish to reset your installation entirely, the installer provides a reset option. To reset the database and all subsystems:

```
foreman-installer --scenario katello --reset
```

To clear all of your on disk Pulp content:

```
foreman-installer --scenario katello --clear-pulp-content
```

To clear all Puppet environments on disk:

```
foreman-installer --scenario katello --clear-puppet-environments
```

### From Git

If you're working off the master branch, use Librarian to pull in all the modules to your local checkout:

```
$ git clone https://github.com/Katello/katello-installer.git
$ bundle install
$ librarian-puppet install --path modules/
$ bin/katello-installer
```

### Certificates

Katello installer comes with a default CA used both for the server SSL
certificates as well as the client certificates used for
authentication of the subservices (pulp, foreman-proxy,
subscription-manager etc.).

#### Custom Server Certificates

Katello-installer runs a validation script for passed input
certificate files. One can run it manually as follows:

```
katello-certs-check -c ~/path/to/server.crt\
                    -r ~/path/to/server.crt.req\
                    -k ~/path/to/server.key\
                    -b ~/path/to/cacert.crt
```

The check is performed also as part of the installer script. In case
the script marked the certs as invalid incorrectly, one can skip this
check by passing `--certs-skip-check` to the installer.

**When running the installer for the first time:**

```
foreman-installer --scenario katello\
                  --certs-server-cert ~/path/to/server.crt\
                  --certs-server-cert-req ~/path/to/server.crt.req\
                  --certs-server-key ~/path/to/server.key\
                  --certs-server-ca-cert ~/path/to/cacert.crt
```

Where the `--certs-server-ca-cert` is the CA used for issuing the
server certs (this CA gets distributed to the consumers and Foreman proxies).

For the Foreman proxy, these options are passed as part of the
`foreman-proxy-certs-generate` script:

```
foreman-proxy-certs-generate --foreman-proxy-fqdn "$FOREMAN_PROXY"\
                             --certs-tar ~/$FOREMAN_PROXY-certs.tar\
                             --server-cert ~/path/to/server.crt\
                             --server-cert-req ~/path/to/server.crt.req\
                             --server-key ~/path/to/server.key\
                             --server-ca-cert ~/cacert.crt
```

The rest of the procedure is identical to the default CA setup.

**Setting custom certificates after 'foreman-installer --scenario katello'
was already run.**

The first run of `foreman-installer --scenario katello` uses the default
CA for both server and client certificates. To enforce the custom
certificates to be deployed, on needs to set `--certs-update-server` for
updating the CA certificate and `--certs-update-server-ca` because the
server CA changed as well (and new katello-ca-consumer rpm needs to be
regenerated):

```
foreman-installer --scenario katello\
                  --certs-server-cert ~/path/to/server.crt\
                  --certs-server-cert-req ~/path/to/server.crt.req\
                  --certs-server-key ~/path/to/server.key\
                  --certs-server-ca-cert ~/path/to/cacert.crt\
                  --certs-update-server --certs-update-server-ca
```

After the server CA changes, the new version of the
consumer-ca-consumer rpm needs to be installed on the consumers, as
well as:

```
rpm -Uvh http://katello.example.com/pub/katello-ca-consumer-latest.noarch.rpm
```

When using the custom server CA, the CA needs to be used for
the server certificates on the Foreman proxies as well. The certificates for
the Foreman proxy are deployed to the Foreman proxy through the use of the
`foreman-proxy-certs-generate` script (followed by copying the certs tar to
the Foreman proxy and running the 'foreman-installer --scenario foreman-proxy-content'
to refresh the certificates).:

```
foreman-proxy-certs-generate --foreman-proxy-fqdn "$FOREMAN_PROXY_CONTENT"\
                             --certs-tar ~/$FOREMAN_PROXY_CONTENT-certs.tar\
                             --server-cert ~/path/to/server.crt\
                             --server-cert-req ~/path/to/server.crt.req\
                             --server-key ~/path/to/server.key\
                             --server-ca-cert ~/cacert.crt\
                             --certs-update-server
```

#### Updating Certificates

**On a server**

To regenerate the server certificates when using the default CA or
enforce deploying new certificates for the custom server CA run
the 'foreman-installer --scenario katello' with `--certs-update-server`
option:

```
foreman-installer --scenario katello --certs-update-server
```

To regenerate all the certificates used in the Katello server, there
is a `--certs-update-all`. This will generate and deploy the
certificates as well as restart corresponding services.

**On a Foreman proxy**

For updating the certificates on a Foreman proxy pass the same
options (either `--certs-update-server` or `--certs-update-all`) to
the `foreman-proxy-certs-generate` script. The new certs tar gets generated
that needs to be transferred to the Foreman proxy and then
`foreman-installer --scenario foreman-content-proxy` needs to be re-run to apply
the updates and restart corresponding services.
