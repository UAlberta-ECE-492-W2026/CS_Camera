/**
 * Photodiode/Sensor Module - Implementation
 */

#include "photodiode.h"
#include "hardware/adc.h"
#include "hardware/gpio.h"
#include <stdio.h>
#include <stdint.h>

#define ADC_INPUT_PIN 26       // GPIO 26 (ADC0)
#define ADC_CHANNEL 0          // ADC channel 0
#define ADC_VREF_MV 3300       // 3.3V reference
#define ADC_MAX_VALUE 4095     // 12-bit ADC

static bool is_initialized = false;

bool sensor_init(void) {
    // Initialize ADC hardware
    adc_init();
    
    // Configure GPIO for ADC input
    adc_gpio_init(ADC_INPUT_PIN);
    
    // Select ADC channel
    adc_select_input(ADC_CHANNEL);
    
    is_initialized = true;
    printf("Sensor module initialized (ADC on GPIO %d)\n", ADC_INPUT_PIN);
    
    return true;
}

uint16_t sensor_read_sample(void) {
    if (!is_initialized) {
        return 0;
    }
    
    // Read ADC value
    return (uint16_t)adc_read();
}

void sensor_read_multiple(uint16_t *buffer, uint32_t num_samples) {
    if (!is_initialized || buffer == NULL) {
        return;
    }
    
    for (uint32_t i = 0; i < num_samples; i++) {
        buffer[i] = sensor_read_sample();
    }
}

bool sensor_start_continuous(uint32_t sample_rate_hz) {
    if (!is_initialized) {
        return false;
    }
    
    // TODO: Implement DMA-based continuous sampling
    printf("Continuous sampling at %u Hz (not yet implemented)\n", sample_rate_hz);
    
    return true;
}

void sensor_stop_continuous(void) {
    // TODO: Stop DMA-based continuous sampling
}

uint16_t sensor_read_voltage_mv(void) {
    if (!is_initialized) {
        return 0;
    }
    
    uint16_t adc_val = sensor_read_sample();
    
    // Convert ADC value to millivolts
    return (uint16_t)((adc_val * ADC_VREF_MV) / ADC_MAX_VALUE);
}
