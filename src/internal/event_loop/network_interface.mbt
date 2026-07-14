// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
pub type NetworkInterfaceSnapshot

///|
extern "C" fn make_network_interface_snapshot() -> NetworkInterfaceSnapshot = "moonbitlang_async_make_network_interface_snapshot"

///|
#borrow(snapshot)
extern "C" fn network_interface_snapshot_length_ffi(
  snapshot : NetworkInterfaceSnapshot,
) -> Int = "moonbitlang_async_network_interface_snapshot_length"

///|
pub fn NetworkInterfaceSnapshot::length(
  snapshot : NetworkInterfaceSnapshot,
) -> Int {
  network_interface_snapshot_length_ffi(snapshot)
}

///|
#borrow(snapshot)
extern "C" fn network_interface_snapshot_name_ffi(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> @c_buffer.Buffer = "moonbitlang_async_network_interface_snapshot_name"

///|
pub fn NetworkInterfaceSnapshot::name(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> String {
  @os_string.decode(network_interface_snapshot_name_ffi(snapshot, index))
}

///|
#borrow(snapshot)
extern "C" fn network_interface_snapshot_ipv4_index_ffi(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> UInt = "moonbitlang_async_network_interface_snapshot_ipv4_index"

///|
pub fn NetworkInterfaceSnapshot::ipv4_index(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> UInt {
  network_interface_snapshot_ipv4_index_ffi(snapshot, index)
}

///|
#borrow(snapshot)
extern "C" fn network_interface_snapshot_ipv6_index_ffi(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> UInt = "moonbitlang_async_network_interface_snapshot_ipv6_index"

///|
pub fn NetworkInterfaceSnapshot::ipv6_index(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> UInt {
  network_interface_snapshot_ipv6_index_ffi(snapshot, index)
}

///|
#borrow(snapshot)
extern "C" fn network_interface_snapshot_is_up_ffi(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> Bool = "moonbitlang_async_network_interface_snapshot_is_up"

///|
pub fn NetworkInterfaceSnapshot::is_up(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> Bool {
  network_interface_snapshot_is_up_ffi(snapshot, index)
}

///|
#borrow(snapshot)
extern "C" fn network_interface_snapshot_is_loopback_ffi(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> Bool = "moonbitlang_async_network_interface_snapshot_is_loopback"

///|
pub fn NetworkInterfaceSnapshot::is_loopback(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> Bool {
  network_interface_snapshot_is_loopback_ffi(snapshot, index)
}

///|
#borrow(snapshot)
extern "C" fn network_interface_snapshot_supports_multicast_ffi(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> Bool = "moonbitlang_async_network_interface_snapshot_supports_multicast"

///|
pub fn NetworkInterfaceSnapshot::supports_multicast(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> Bool {
  network_interface_snapshot_supports_multicast_ffi(snapshot, index)
}

///|
#borrow(snapshot)
extern "C" fn network_interface_snapshot_address_count_ffi(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> Int = "moonbitlang_async_network_interface_snapshot_address_count"

///|
pub fn NetworkInterfaceSnapshot::address_count(
  snapshot : NetworkInterfaceSnapshot,
  index : Int,
) -> Int {
  network_interface_snapshot_address_count_ffi(snapshot, index)
}

///|
#borrow(snapshot)
extern "C" fn network_interface_snapshot_address_size_ffi(
  snapshot : NetworkInterfaceSnapshot,
  interface_index : Int,
  address_index : Int,
) -> Int = "moonbitlang_async_network_interface_snapshot_address_size"

///|
pub fn NetworkInterfaceSnapshot::address_size(
  snapshot : NetworkInterfaceSnapshot,
  interface_index : Int,
  address_index : Int,
) -> Int {
  network_interface_snapshot_address_size_ffi(
    snapshot, interface_index, address_index,
  )
}

///|
#borrow(snapshot, output)
extern "C" fn network_interface_snapshot_fill_address_ffi(
  snapshot : NetworkInterfaceSnapshot,
  interface_index : Int,
  address_index : Int,
  output : Bytes,
) -> Unit = "moonbitlang_async_network_interface_snapshot_fill_address"

///|
pub fn NetworkInterfaceSnapshot::fill_address(
  snapshot : NetworkInterfaceSnapshot,
  interface_index : Int,
  address_index : Int,
  output : Bytes,
) -> Unit {
  network_interface_snapshot_fill_address_ffi(
    snapshot, interface_index, address_index, output,
  )
}

///|
#borrow(snapshot)
extern "C" fn network_interface_snapshot_prefix_length_ffi(
  snapshot : NetworkInterfaceSnapshot,
  interface_index : Int,
  address_index : Int,
) -> Int = "moonbitlang_async_network_interface_snapshot_prefix_length"

///|
pub fn NetworkInterfaceSnapshot::prefix_length(
  snapshot : NetworkInterfaceSnapshot,
  interface_index : Int,
  address_index : Int,
) -> Int {
  network_interface_snapshot_prefix_length_ffi(
    snapshot, interface_index, address_index,
  )
}

///|
pub async fn network_interfaces(context~ : String) -> NetworkInterfaceSnapshot {
  @coroutine.check_cancellation()
  let output = make_network_interface_snapshot()
  let job = Job::network_interfaces(output)
  let mut completed = false
  // Enumeration is not cancellable. Let the worker and its cleanup continue in
  // the background while allowing the caller to observe cancellation promptly.
  try
    @coroutine.spawn(() => {
      defer job.free()
      ignore(perform_job_in_worker(job, context~))
      completed = true
    }).wait()
  catch {
    _ if completed => return output
    error => raise error
  } noraise {
    _ => output
  }
}
