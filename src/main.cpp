#include <cassert>
#include <iostream>

#include <CL/sycl.hpp>

using data_type = float;

namespace sycl = cl::sycl;

std::vector<data_type> add(sycl::queue& q, const std::vector<data_type>& a,
                           const std::vector<data_type>& b) {
  std::vector<data_type> c(a.size());

  assert(a.size() == b.size());
  sycl::range<1> work_items{a.size()};

  {
    sycl::buffer<data_type> buff_a(a.data(), a.size());
    sycl::buffer<data_type> buff_b(b.data(), b.size());
    sycl::buffer<data_type> buff_c(c.data(), c.size());

    q.submit([&](sycl::handler& cgh) {
      auto access_a = buff_a.get_access<sycl::access::mode::read>(cgh);
      auto access_b = buff_b.get_access<sycl::access::mode::read>(cgh);
      auto access_c = buff_c.get_access<sycl::access::mode::write>(cgh);

      cgh.parallel_for<class vector_add>(work_items, [=](sycl::id<1> tid) {
        access_c[tid] = access_a[tid] + access_b[tid];
      });
    });
  }
  return c;
}

int main() {
  sycl::queue q{sycl::default_selector_v};

  std::cout << "Running on: "
            << q.get_device().get_info<sycl::info::device::name>() << std::endl;

  std::vector<data_type> a = {1.f, 2.f, 3.f, 4.f, 5.f};
  std::vector<data_type> b = {-1.f, 2.f, -3.f, 4.f, -5.f};
  auto result = add(q, a, b);

  std::cout << "Result: " << std::endl;
  for (const auto x : result) {
    std::cout << x << std::endl;
  }
}
