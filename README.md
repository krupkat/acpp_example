# acpp_example
Build an [AdaptiveCpp](https://github.com/AdaptiveCpp/AdaptiveCpp) sample app inside docker.

- Enabled backends: cpu, cuda
  - For gpu support in runtime, [nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) is recommended
- Disabled backends: rocm (amd), spirv (intel)

## Docker compose

```bash
docker compose build
docker compose up
```

## Manual build

```bash
docker build . -t krupkat/acpp

# run on gpu
docker run --device=nvidia.com/gpu=all -v ~/.local/share/acpp:/kernel_cache krupkat/acpp:latest

# run on cpu
docker run -v ~/.local/share/acpp:/kernel_cache krupkat/acpp:latest
```
