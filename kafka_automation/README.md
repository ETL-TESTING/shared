# Running Locally
## Install Steply (macOS / Linux, no Java required):
```
bashcurl -fsSL https://raw.githubusercontent.com/QABEES/steply/main/scripts/install.sh | bash
```
## Run the Kafka produce test:
```
bashsteply --scenario tests/produce_order_message.json --target-env env/kafka_local_server.properties
```

## Install Steply (Windows):
Follow Windows OS instructions from here:
- https://github.com/QABEES/steply#windows-os

## Download Zip and Install Manually (Mac/Unix):
You should have JAVA_HOME set, then follow the steps below:
- https://github.com/QABEES/steply#manual-install-mac--linux--unix
