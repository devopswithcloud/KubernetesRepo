## Config Map

* A ConfigMap allows us to define application related data.
* ConfigMap can be create through a literal value or from a file
* Secret is also much like config map but in secrets the values are base64 encoded
* Kubernetes secretes has 3 available commands
    * generic: generic secret holds any key value pair
    * tls: secret for holding private-public key for communicating with TLS protocol
    * docker-registry: This is special kind of secret that stores usernames and passwords to connect to private registries