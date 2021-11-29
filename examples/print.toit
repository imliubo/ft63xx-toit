// MIT License
// Copyright (c) 2021 IAMLIUBO
// https://github.com/imliubo

import gpio
import i2c
import ft63xx
import fixed_point show FixedPoint
import m5stack_core2

main:
  clock := gpio.Pin 22
  data := gpio.Pin 21
  // I2C init
  bus := i2c.Bus
    --sda=data
    --scl=clock

  // M5Stack Core2 init.
  power := m5stack_core2.Power --clock=clock --data=data
  print bus.scan
  // FT63xx init.
  ft_device := bus.device ft63xx.I2C_ADDRESS
  driver := ft63xx.Driver ft_device

  coord := ft63xx.Coordinate 0 0 false

  while true:
    // Read FT63xx.
    coord = driver.get_coords
    // if touched print the coordinate.
    if coord.s:
      print "X: $coord.x Y: $coord.y"
    sleep --ms=20
