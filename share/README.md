# Storj SDK - Share

To enable scaling of the share nodes we will need to genreate unique ID (key)'s for each farmer. Once an ID (key) is generated, we should cache this in its config file. If the config file and its associated data is removed, a new ID (key) is created and written to the config file.

_ALL_ state for a farmer is saved in `data/farmer_${i}` where where `${i}` is the index of the farmer. This index might not correspond to the id given by `docker-compose` (i.e. `data/farmer_2` might belong to `storjsdk_share_5`) since each farmer is racing to claim directories in sequential order. If the folder for a farmer does not exist, the farmer will assume it has no state and create everything from scratch.
