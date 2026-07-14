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
/// A unicast address assigned to a network interface.
pub struct InterfaceAddress {
  /// The address with port zero. IPv6 link-local addresses include their zone
  /// index in `Addr::scope_id()`.
  address : Addr
  /// The number of leading network-prefix bits.
  prefix_len : Int
} derive(Debug, Eq)

///|
/// A point-in-time snapshot of an operating-system network interface.
pub struct NetworkInterface {
  /// The platform interface name or alias.
  name : String
  /// The IPv4 interface index, when supplied by the platform.
  ipv4_index : UInt?
  /// The IPv6 interface index, when supplied by the platform.
  ipv6_index : UInt?
  is_up : Bool
  is_loopback : Bool
  supports_multicast : Bool
  addresses : ReadOnlyArray[InterfaceAddress]
} derive(Debug, Eq)

///|
/// List the system's network interfaces as an immutable snapshot.
///
/// The returned order is platform-defined and may change between calls.
pub async fn NetworkInterface::list() -> ReadOnlyArray[NetworkInterface] {
  let snapshot = @event_loop.network_interfaces(
    context="@socket.NetworkInterface::list()",
  )
  let interfaces = []
  for interface_index in 0..<snapshot.length() {
    let addresses = []
    for address_index in 0..<snapshot.address_count(interface_index) {
      let address_size = snapshot.address_size(interface_index, address_index)
      let raw_address = Bytes::make(address_size, b'\x00')
      snapshot.fill_address(interface_index, address_index, raw_address)
      addresses.push({
        address: Addr(raw_address),
        prefix_len: snapshot.prefix_length(interface_index, address_index),
      })
    }
    let raw_ipv4_index = snapshot.ipv4_index(interface_index)
    let raw_ipv6_index = snapshot.ipv6_index(interface_index)
    interfaces.push({
      name: snapshot.name(interface_index),
      ipv4_index: if raw_ipv4_index == 0 {
        None
      } else {
        Some(raw_ipv4_index)
      },
      ipv6_index: if raw_ipv6_index == 0 {
        None
      } else {
        Some(raw_ipv6_index)
      },
      is_up: snapshot.is_up(interface_index),
      is_loopback: snapshot.is_loopback(interface_index),
      supports_multicast: snapshot.supports_multicast(interface_index),
      addresses: ReadOnlyArray::from_array(addresses),
    })
  }
  ReadOnlyArray::from_array(interfaces)
}
