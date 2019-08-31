#!/bin/bash

function shutdown() {
  echo "Stopping Container..."
}

trap shutdown SIGINT

echo "Starting Container..."
sleep infinity
