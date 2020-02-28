# docker-minecraft

Example:

```bash
podman build ./ -t dbkmc:latest

cd ${MODS_FOLDER}/${MOD_PACK}
ln -s forge-*-universal.jar forge.jar

podman run --name modpack-test -td \
-p 25566:25565 -e LOAD_MODPACK="true" \
-e JAR_NAME="forge" \
-e ACCEPT_EULA="true" \
-e XMX_SIZE="16000" -e XMS_SIZE="16000" \
-v "${PWD}":/mod_source/:ro,Z \
dbkmc
