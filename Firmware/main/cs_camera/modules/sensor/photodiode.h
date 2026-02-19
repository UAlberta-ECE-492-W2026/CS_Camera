/**
 * Photodiode/Sensor Module - Interface
 * Handles ADC sampling and analog data acquisition
 */

#ifndef PHOTODIODE_H
#define PHOTODIODE_H

#include <stdbool.h>
#include <stdint.h>

/**
 * Initialize the photodiode sensor and ADC
 * @return true if successful, false otherwise
 */
bool sensor_init(void);

/**
 * Read a single sample from the photodiode
 * @return ADC value (0-4095 for 12-bit ADC)
 */
uint16_t sensor_read_sample(void);

/**
 * Read multiple samples from the photodiode
 * @param buffer Buffer to store samples
 * @param num_samples Number of samples to read
 */
void sensor_read_multiple(uint16_t *buffer, uint32_t num_samples);

/**
 * Start continuous sampling mode
 * @param sample_rate_hz Desired sampling rate in Hz
 * @return true if successful
 */
bool sensor_start_continuous(uint32_t sample_rate_hz);

/**
 * Stop continuous sampling mode
 */
void sensor_stop_continuous(void);

/**
 * Get the current sensor value as voltage
 * @return Voltage in millivolts (0-3300 mV for 3.3V ref)
 */
uint16_t sensor_read_voltage_mv(void);

#endif // PHOTODIODE_H
