# AHT20

A driver for the ASAIR AHT10/AHT20/AHT25 temperature and humidity sensors.

This is a fork of https://github.com/davidlao2k/aht20-driver by David Lao.

## How to use
This code provides simple read functions for temperature, humidity, and dew point.
- `read-temperature`:  Temperature returned in degrees celcius (float).
- `read-humidity`: Relative humidity returned in percentage value (float).
- `read-dew-point`: The temperature at which condensation would start to form,
  in degrees celcius (float).

Functions can be used in combination with popular ENS160/AHT21 combo modules,
by using the ENS160 driver alongside.

This code has been tested with an AHT21 module.  Feedback for other compatible
modules would be appreciated.

## Examples
For an I2C example, see the [examples](./examples) folder.

## Issues
If there are any issues, changes, or any other kind of feedback, please
[raise an issue](./issues). Feedback is welcome and appreciated!

## Disclaimer
- All trademarks belong to their respective owners.
- No warranties for this work, express or implied.

## Credits
- [davidlao2k](https://github.com/davidlao2k/aht20-driver) for the original code.
- [floitsch](https://github.com/floitsch) for improvements.
