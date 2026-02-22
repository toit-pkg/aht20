// Copyright (C) 2026 Toitware Contributors. All rights reserved.
// Original code Copyright (c) 2022 David Lao.
// Use of this source code is governed by an MIT-style license that can be found
// in the LICENSE file.
import binary
import serial.device as serial
import math

/**
Driver for the AHT10/AHT15/AHT20/AHT21/AHT25 sensors.
*/
class Aht20:
  static I2C-ADDRESS   ::= 0x38

  static INIT-CMD_     ::= 0xBE
  static MEASURE-CMD_  ::= 0xAC
  static RESET-CMD_    ::= 0xBA
  static STATUS-CMD_   ::= 0x71

  static WATER-VAPOR ::= 17.62
  static BAROMETRIC-PRESSURE ::= 243.5

  dev_/serial.Device ::= ?

  constructor dev/serial.Device:
    dev_ = dev

    // Initialize the sensor.
    sleep --ms=40
    dev_.write #[INIT-CMD_, 0x08, 0x00]

    // Requires 100ms after startup before reading temperature.  Some time is taken
    // to boot the ESP32 - remaining time assumed is 10ms.
    sleep --ms=10

    // Verify the calibration bit.
    s := read-status
    if (s & 0x08 != 0x08) :
      throw "failed initialization"

  /**
  Reads the humidity.

  Humidity is returned in percentage value.
  */
  read-humidity:
    dev_.write #[MEASURE-CMD_, 0x33, 0x00]
    sleep --ms=80

    check-busy-bit_
    dat := dev_.read 6
    return compute-hum_ dat

  /**
  Reads the temperature.

  Temperature is returned in degrees Celsius.
  */
  read-temperature:
    dev_.write #[MEASURE-CMD_, 0x33, 0x00]
    sleep --ms=80

    check-busy-bit_
    dat := dev_.read 6
    return compute-temp_ dat

  /**
  Calculates the dew point.

  If moist air cools down enough, it reaches a point where it cannot hold all
    the water vapor it currently contains. That temperature is the dew point.
    Relative humidity (RH) depends on temperature whereas the dew point does not
    change unless the actual amount of moisture in the air changes.  This means
    it is a better measure of true moisture content, independent of current
    temperature.  In other words - it is the temperature at which condensation
    would start to form.
  */
  read-dew-point:
    dev_.write #[MEASURE-CMD_, 0x33, 0x00]
    sleep --ms=80

    check-busy-bit_
    dat := dev_.read 6
    hum := compute-hum_ dat
    temp := compute-temp_ dat

    gamma := math.log(hum / 100) + WATER-VAPOR * temp / (BAROMETRIC-PRESSURE + temp)
    return BAROMETRIC-PRESSURE * gamma / (WATER-VAPOR - gamma)

  /**
  Compute humidity from the raw byte array.
  */
  compute-hum_ dat:
    hum := ((dat[1] << 16) | (dat[2] << 8) | dat[3]) >> 4
    return hum * 100.0 / 1048576

  /**
  Compute temperature from the raw byte array.
  */
  compute-temp_ dat:
    temp := ((dat[3] & 0x0F) << 16) | (dat[4] << 8) | dat[5]
    return ((200.0 * temp) / 1048576) - 50

  /**
  Wait for busy bit to clear to indicate idle state.
  */
  check-busy-bit_:
    tries := 5
    while (read-status & 0x80 != 0):
      tries--
      if tries == 0: throw "sensor busy!"
      sleep --ms=1

  /**
  Perform a soft reset.
  */
  soft-reset:
    dev_.write #[RESET-CMD_]

  /**
  Read sensor status.
  */
  read-status:
    dev_.write #[STATUS-CMD_]
    return (dev_.read 1)[0]
