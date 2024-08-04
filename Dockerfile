# build
FROM nvidia/cuda:12.5.1-devel-ubuntu24.04 AS dev

WORKDIR /tmp

RUN gpg --no-default-keyring --homedir /tmp \
      --keyring /etc/apt/keyrings/llvm.gpg \
      --keyserver hkp://keyserver.ubuntu.com:80 \
      --recv-keys 15CF4D18AF4F7421

COPY <<EOF /etc/apt/sources.list.d/llvm.list
deb [signed-by=/etc/apt/keyrings/llvm.gpg] http://apt.llvm.org/noble/ llvm-toolchain-noble-18 main
deb-src [signed-by=/etc/apt/keyrings/llvm.gpg] http://apt.llvm.org/noble/ llvm-toolchain-noble-18 main
EOF

RUN apt update && \
    apt install -y cmake git ninja-build && \
    apt install -y clang-18 libclang-18-dev libomp-18-dev llvm-18-dev && \
    apt install -y libboost-test-dev libboost-context-dev libboost-fiber-dev

RUN ln -s /usr/lib/x86_64-linux-gnu/libLLVM-18.so.1 /usr/lib/llvm-18/lib/libLLVM.so

RUN git clone https://github.com/AdaptiveCpp/AdaptiveCpp --depth 1 --branch v24.06.0 && \
    cmake -S AdaptiveCpp -B build_acpp -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/acpp \
      -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
      -DACPP_COMPILER_FEATURE_PROFILE=full \
      -DWITH_CUDA_BACKEND=ON \
      -DWITH_ROCM_BACKEND=OFF \
      -DWITH_OPENCL_BACKEND=OFF \
      -DLLVM_ROOT=/usr/lib/llvm-18 && \
    cmake --build build_acpp --target install

COPY src /tmp/src

RUN cmake -S src -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DAdaptiveCpp_ROOT=/acpp \
      -DACPP_TARGETS=generic && \
    cmake --build build

# deploy
FROM nvidia/cuda:12.5.1-base-ubuntu24.04 AS runtime

COPY --from=dev /etc/apt/sources.list.d/llvm.list /etc/apt/sources.list.d/llvm.list
COPY --from=dev /etc/apt/keyrings/llvm.gpg /etc/apt/keyrings/llvm.gpg

RUN apt update && apt install -y --no-install-recommends clang-18

ENV ACPP_APPDB_DIR=/kernel_cache

COPY --from=dev /acpp /acpp
COPY --from=dev /usr/local/cuda-12.5/nvvm/libdevice /usr/local/cuda-12.5/nvvm/libdevice

COPY --from=dev /tmp/build/acpp-example /acpp-example

ENTRYPOINT ["/acpp-example"]
