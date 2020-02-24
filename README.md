# docker-minecraft


Example:

podman build ./ -t dbkmc:latest

podman run --name modpack-test -it \
-p 25566:25565 -e LOAD_MODPACK="true" \
-e JAR_NAME="forge-1.12.2-14.23.5.2847-universal" \
-e ACCEPT_EULA="true" \
-e XMX_SIZE="16000" -e XMS_SIZE="16000" \
-v "${PWD}":/mod_source/:ro,Z \
dbkmc
