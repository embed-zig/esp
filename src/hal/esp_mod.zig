const adc = @import("adc.zig");
pub const display = @import("display.zig");
const gpio = @import("gpio.zig");
const hci = @import("hci.zig");
const i2c = @import("i2c.zig");
const i2s = @import("i2s.zig");
const kvs = @import("kvs.zig");
const led = @import("led.zig");
const led_strip = @import("led_strip.zig");
const audio_es7210_es8311 = @import("audio_system/es7210_es8311.zig");
const pwm = @import("pwm.zig");
const rtc = @import("rtc.zig");
const spi = @import("spi.zig");
const temp_sensor = @import("temp_sensor.zig");
const uart = @import("uart.zig");
const wifi = @import("wifi.zig");
const hal = @import("embed").hal;

const gpio_spec = struct {
    pub const Driver = gpio.Driver;
    pub const meta = .{ .id = "esp.gpio" };
};
pub const Gpio = hal.gpio.from(gpio_spec);

const hci_spec = struct {
    pub const Driver = hci.Driver;
    pub const meta = .{ .id = "esp.hci" };
};
pub const Hci = hal.hci.from(hci_spec);

const adc_spec = struct {
    pub const Driver = adc.Driver;
    pub const meta = .{ .id = "esp.adc" };
};
pub const Adc = hal.adc.from(adc_spec);

const led_spec = struct {
    pub const Driver = led.Driver;
    pub const meta = .{ .id = "esp.led" };
};
pub const Led = hal.led.from(led_spec);

const led_strip_spec = struct {
    pub const Driver = led_strip.Driver;
    pub const meta = .{ .id = "esp.led_strip" };
};
pub const LedStrip = hal.led_strip.from(led_strip_spec);

const i2c_spec = struct {
    pub const Driver = i2c.Driver;
    pub const DeviceHandle = i2c.Driver.DeviceHandle;
    pub const meta = .{ .id = "esp.i2c" };
};
pub const I2c = hal.i2c.from(i2c_spec);

const spi_spec = struct {
    pub const Driver = spi.Driver;
    pub const meta = .{ .id = "esp.spi" };
};
pub const Spi = hal.spi.from(spi_spec);

const i2s_spec = struct {
    pub const Driver = i2s.Driver;
    pub const EndpointHandle = i2s.EndpointHandle;
    pub const meta = .{ .id = "esp.i2s" };
};
pub const I2s = hal.i2s.from(i2s_spec);

const pwm_spec = struct {
    pub const Driver = pwm.Driver;
    pub const meta = .{ .id = "esp.pwm" };
};
pub const Pwm = hal.pwm.from(pwm_spec);

const uart_spec = struct {
    pub const Driver = uart.Driver;
    pub const meta = .{ .id = "esp.uart" };
};
pub const Uart = hal.uart.from(uart_spec);

const wifi_spec = struct {
    pub const Driver = wifi.Driver;
    pub const meta = .{ .id = "esp.wifi" };
};
pub const Wifi = hal.wifi.from(wifi_spec);

const kvs_spec = struct {
    pub const Driver = kvs.Driver;
    pub const meta = .{ .id = "esp.kvs" };
};
pub const Kvs = hal.kvs.from(kvs_spec);

const display_spec = struct {
    pub const Driver = display.Driver;
    pub const meta = .{ .id = "esp.display" };
};
pub const Display = hal.display.from(display_spec);

const audio_system_es7210_es8311_spec = struct {
    pub const Driver = audio_es7210_es8311.Driver;
    pub const meta = .{ .id = "esp.audio_system.es7210_es8311" };
    pub const config = hal.audio_system.Config{ .sample_rate = 16000, .mic_count = 4 };
};
pub const AudioSystemEs7210Es8311 = hal.audio_system.from(audio_system_es7210_es8311_spec);

pub const audio_system = struct {
    pub const es7210_es8311 = audio_es7210_es8311;
};

pub const audio_system_config = audio_es7210_es8311;

const rtc_reader_spec = struct {
    pub const Driver = rtc.Driver;
    pub const meta = .{ .id = "esp.rtc" };
};
pub const RtcReader = hal.rtc.reader.from(rtc_reader_spec);

const rtc_writer_spec = struct {
    pub const Driver = rtc.Driver;
    pub const meta = .{ .id = "esp.rtc" };
};
pub const RtcWriter = hal.rtc.writer.from(rtc_writer_spec);

const temp_sensor_spec = struct {
    pub const Driver = temp_sensor.Driver;
    pub const meta = .{ .id = "esp.temp_sensor" };
};
pub const TempSensor = hal.temp_sensor.from(temp_sensor_spec);
