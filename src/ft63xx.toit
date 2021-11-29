// MIT License

// Copyright (c) 2021 IAMLIUBO https://github.com/imliubo

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import binary
import serial.device as serial
import serial.registers as serial
import gpio
import math

I2C_ADDRESS ::= 0x38

class Coordinate:
  // x: X axis coordinate.
  // y: Y axis coordinate.
  // s: Touch screen status, true -> touched, false -> untouched.
  x /int := 0
  y /int := 0
  s /bool := false

  // We don't need to specify the type for constructor
  // arguments that are written directly to a typed field.
  constructor .x .y .s:

/**
Capacitive touch screen FT63XX series driver.
*/
class Driver:
  // Registers.
  static FT5x06_VENDID_REG    ::= 0xA8
  static FT5x06_POWER_REG     ::= 0x87
  static FT5x06_PERIODACTIVE  ::= 0x88
  static FT5x06_INTMODE_REG   ::= 0xA4

  static FT5x06_MONITOR       ::= 0x01
  static FT5x06_SLEEP_IN      ::= 0x03

  reg_/serial.Registers ::= ?
  pin_/gpio.Pin ::= ?
  coord_/Coordinate ::= ?

  constructor
      dev/serial.Device
      int_pin/int? = 39:

    reg_ = dev.registers
    pin_ = gpio.Pin int_pin --input=true
    coord_ = Coordinate 0 0 false

    init

  /**
  Initializes the chip.
  */
  init:
    reg_.write_u8 FT5x06_INTMODE_REG 0x00

  /**
  Is pressed?
  */
  is_pressed -> bool:
    return pin_.get == 0

  /**
  Read the Coordinate.
  */
  get_coords -> Coordinate:
    if not is_pressed:
      coord_.s = false
      return coord_

    data := reg_.read_bytes 0x02 11
    if data[0] > 2:
      coord_.s = false
      return coord_
    else:
      coord_.x = ((data[1] << 8) | data[2]) & 0x0FFF
      coord_.y = ((data[3] << 8) | data[4]) & 0x0FFF
      coord_.s = true
      return coord_
