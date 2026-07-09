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
fn sample_ipv6_bytes() -> FixedArray[Byte] {
  let ip = FixedArray::make(16, b'\x00')
  ip[0] = b'\x20'
  ip[1] = b'\x01'
  ip[2] = b'\x0D'
  ip[3] = b'\xB8'
  ip[15] = b'\x01'
  ip
}

///|
test "Construct IPv6 address" {
  let addr = @socket.Addr::new_ipv6(sample_ipv6_bytes(), 53)
  assert_eq(addr.to_string(), "[2001:db8::1]:53")
  assert_eq(addr.is_ipv6(), true)
  assert_eq(addr.port(), 53)
  assert_eq(addr.scope_id(), 0)
  assert_eq(
    addr.ip_bytes(),
    b"\x20\x01\x0D\xB8\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01",
  )
  let scoped_addr = @socket.Addr::new_ipv6(
    sample_ipv6_bytes(),
    5353,
    scope_id=7,
  )
  assert_eq(scoped_addr.scope_id(), 7)
}

///|
test "Construct IPv6 special addresses" {
  assert_eq(@socket.Addr::any_ipv6().to_string(), "[::]:0")
  assert_eq(@socket.Addr::any_ipv6(port=5353).to_string(), "[::]:5353")
  assert_eq(@socket.Addr::loopback_ipv6(port=8080).to_string(), "[::1]:8080")
}

///|
test "Read address bytes" {
  let addr = @socket.Addr::new(0x7F000001, 80)
  assert_eq(addr.ip_bytes(), b"\x7F\x00\x00\x01")
  assert_eq(addr.scope_id(), 0)
}

///|
test "Construct invalid IPv6 address" {
  @test.assert_raise(() => {
    @socket.Addr::new_ipv6(FixedArray::make(15, b'\x00'), 53)
  })
  @test.assert_raise(() => @socket.Addr::new_ipv6(sample_ipv6_bytes(), -1))
  @test.assert_raise(() => @socket.Addr::new_ipv6(sample_ipv6_bytes(), 65536))
}

///|
test "Parse IPv4 address" {
  assert_eq(@socket.Addr::parse("127.0.0.1:8080").to_string(), "127.0.0.1:8080")
  assert_eq(@socket.Addr::parse("0.0.0.0:8080").to_string(), "0.0.0.0:8080")
  assert_eq(
    @socket.Addr::parse("255.255.255.255:8080").to_string(),
    "255.255.255.255:8080",
  )
  assert_eq(
    @socket.Addr::parse("172.31.254.253:8080").to_string(),
    "172.31.254.253:8080",
  )
}

///|
test "Parse invalid IPv4 address" {
  // Too short
  @test.assert_raise(() => @socket.Addr::parse("127.0.0.1"))

  // Too long
  @test.assert_raise(() => @socket.Addr::parse("127.0.0.1:8080:8080"))

  // Invalid IP, out of range
  @test.assert_raise(() => @socket.Addr::parse("256.0.0.1:8080"))
}

///|
test "Parse IPv6 address" {
  let addr = @socket.Addr::parse("[2a02:6b8::11:11]:8080")
  assert_eq(addr.to_string(), "[2a02:6b8::11:11]:8080")
  assert_eq(
    @socket.Addr::parse("[0:0:0:0:0:0:0:0]:8080").to_string(),
    "[::]:8080",
  )
  assert_eq(
    @socket.Addr::parse("[0:0:0:0:0:0:0:1]:8080").to_string(),
    "[::1]:8080",
  )
  assert_eq(@socket.Addr::parse("[::1]:8080").to_string(), "[::1]:8080")
  assert_eq(
    @socket.Addr::parse("[::1%\{test_interface.force()}]:8080").to_string(),
    "[::1%\{test_interface.force()}]:8080",
  )
  assert_eq(
    @socket.Addr::parse("[::1%\{test_interface_index.force()}]:8080").to_string(),
    "[::1%\{test_interface.force()}]:8080",
  )
}

///|
test "Parse invalid IPv6 address" {
  // Too short
  @test.assert_raise(() => @socket.Addr::parse("[1:2:3:4:5:6:7:8080]"))

  // Too long
  @test.assert_raise(() => @socket.Addr::parse("[1:2:3:4:5:6:7:8:9:8080]"))

  // triple colon
  @test.assert_raise(() => @socket.Addr::parse("[1:2:::6:7:8]:8080]"))

  // two double colons
  @test.assert_raise(() => @socket.Addr::parse("[1:2::6::8]:8080]"))
}

///|
test "Parse IPv6 address with ipv4" {
  let addr = @socket.Addr::parse("[::ffff:192.0.2.33]:8080")
  assert_eq(addr.to_string(), "[::ffff:192.0.2.33]:8080")
  let addr = @socket.Addr::parse("[::FFFF:192.0.2.33]:8080")
  assert_eq(addr.to_string(), "[::ffff:192.0.2.33]:8080")
  // Not enough groups
  @test.assert_raise(() => @socket.Addr::parse("[1:2:3:4:5:127.0.0.1]:8080"))
  // Too many groups
  @test.assert_raise(() => @socket.Addr::parse("[1:2:3:4:5:6:7:127.0.0.1]:8080"))
}
