extern fn espz_system_restart() noreturn;

pub fn restart() noreturn {
    espz_system_restart();
}
