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
fn is_ipv6_link_local(address : @socket.Addr) -> Bool {
  if !address.is_ipv6() {
    return false
  }
  let bytes = address.ip_bytes()
  bytes[0] == b'\xFE' && (bytes[1].to_int() & 0xC0) == 0x80
}

///|
async test "list network interfaces" {
  let interfaces = @socket.NetworkInterface::list()
  assert_true(interfaces.length() > 0)
  for interface_index, interface in interfaces {
    assert_true(interface.name.length() > 0)
    assert_true(
      interface.ipv4_index is Some(_) || interface.ipv6_index is Some(_),
    )
    for previous_index in 0..<interface_index {
      assert_true(interface.name != interfaces[previous_index].name)
    }
    for assigned in interface.addresses {
      assert_eq(assigned.address.port(), 0)
      if assigned.address.is_ipv6() {
        assert_true(0 <= assigned.prefix_len && assigned.prefix_len <= 128)
        assert_true(interface.ipv6_index is Some(_))
        if is_ipv6_link_local(assigned.address) {
          guard interface.ipv6_index is Some(ipv6_index) else {
            fail("IPv6 link-local address has no interface index")
          }
          assert_eq(assigned.address.scope_id(), ipv6_index)
        }
      } else {
        assert_true(0 <= assigned.prefix_len && assigned.prefix_len <= 32)
        assert_true(interface.ipv4_index is Some(_))
        assert_eq(assigned.address.scope_id(), 0)
      }
    }
  }
}
