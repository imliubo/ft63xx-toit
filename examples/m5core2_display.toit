// MIT License
// Copyright (c) 2021 IAMLIUBO
// https://github.com/imliubo

import i2c
import gpio

import ft63xx
import m5stack_core2

import bitmap show *
import color_tft show *
import font show *
import font.x11_100dpi.sans.sans_14_bold as sans_14_bold
import font.x11_100dpi.sans.sans_24_bold as sans_24_bold
import pixel_display show *
import pixel_display.histogram show TrueColorHistogram
import pixel_display.texture show *
import pixel_display.true_color show *


main:
  // I2C Pin define.
  clock := gpio.Pin 22
  data := gpio.Pin 21

  // Create the power object and initialize the power config
  // to its default values.  Resets the LCD display and switches
  // on the LCD backlight and the green power LED.

  // AXP192 Init.
  power := m5stack_core2.Power --clock=clock --data=data

  // FT63xx Init.
  bus := i2c.Bus --sda=data --scl=clock
  device := bus.device ft63xx.I2C_ADDRESS
  ft63xx_dev := ft63xx.Driver device
  coord := ft63xx.Coordinate 0 0 false

  // Get TFT driver.
  tft := m5stack_core2.display

  tft.background = get_rgb 0x12 0x03 0x25

  // Font.
  sans_14_big := Font [sans_14_bold.ASCII]
  sans_14_big_context := tft.context --landscape --color=WHITE --font=sans_14_big
  sans_24_big := Font [sans_24_bold.ASCII]
  sans_24_big_context := tft.context --landscape --color=WHITE --font=sans_24_big

  // Display string.
  title_str := tft.text (sans_24_big_context.with --alignment=TEXT_TEXTURE_ALIGN_CENTER) 160 30 "TOIT M5Core2"
  coord_str := tft.text (sans_14_big_context.with --alignment=TEXT_TEXTURE_ALIGN_CENTER) 160 90 "X: 0  Y: 0"

  tft.draw

  while true:
    // Read FT63xx.
    coord = ft63xx_dev.get_coords
    // Update the display string.
    if coord.s:
      coord_str.text = "X: $(%d coord.x)  Y: $(%d coord.y)"

    tft.draw  // Update screen.

    sleep --ms=10
