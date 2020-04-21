#!/bin/bash

PRJ_N="stm32f10x"
echo "Project name (example: stm32f10x):"
read PRJ_N

Series_N="f1"
echo "Series MCU name (example: f1):"
read Series_N

Prog_CFG="interface/stlink-v2.cfg"
echo "Config File Prog (example: interface/stlink-v2.cfg):"
read Prog_CFG

MCU_CFG="target/stm32f1x.cfg"
echo "Config File MCU (example: target/stm32f1x.cfg):"
read MCU_CFG

MCU_SVD="STM32F103xx.svd"
echo "This file must be taken on the MCU manufacturers website and placed in the same directory as the script"
echo "Name SVD File (example: STM32F103xx.svd):"
read MCU_SVD

#создать новый проект и иерархию папок
cargo new $PRJ_N

mkdir $PRJ_N/.vscode/
mkdir $PRJ_N/.cargo/

cp $MCU_SVD $PRJ_N/.vscode/

cd $PRJ_N

#установим целевую платформу для компилятора
rustup target add thumbv7m-none-eabi

#создаем файл конфигураций для обозначили цель компиляции по умолчанию
cat > .cargo/config << EOF
[target.thumbv7m-none-eabi]

[target.'cfg(all(target_arch = "arm", target_os = "none"))']

rustflags = ["-C", "link-arg=-Tlink.x"]

[build]
target = "thumbv7m-none-eabi"  # Cortex-M3
EOF

#файл с указанием разметки памяти нашего контроллера
cat > memory.x << EOF
MEMORY
{
 FLASH : ORIGIN = 0x08000000, LENGTH = 64K
 RAM : ORIGIN = 0x20000000, LENGTH = 20K
}
EOF
echo "Do not forget to indicate the memory layout of your MCU in memory.x"

#подключим необходимые библиотеки в файле Cargo.toml
cat >> Cargo.toml << EOF
# Зависимости для разработки под процессор Cortex-M3
cortex-m = "*"
cortex-m-rt = "*"
cortex-m-semihosting = "*"
panic-halt = "*"
nb = "0.1.2"
embedded-hal = "0.2.3"

# Пакет для разработки под отладочные платы stm32${Series_N}
[dependencies.stm32${Series_N}xx-hal]
version = "0.5.2"
features = ["stm32${Series_N}00", "rt"]

# Позволяет использовать "cargo fix"!
[[bin]]
name = "$PRJ_N"
test = false
bench = false

# Включение оптимизации кода
[profile.release]
codegen-units = 1 # Лучшая оптимизация
debug = true # Нормальные символы, не увеличивающие размер на Flash памяти
#lto = true # Лучшая оптимизация
EOF

#создаем файлы для системы сборки
cat > .vscode/launch.json << EOF
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Rust Cortex Debug",
            "type": "cortex-debug",
            "request": "launch",
            "servertype": "openocd",
            "cwd": "\${workspaceFolder}",
            "executable": "target/thumbv7m-none-eabi/release/$PRJ_N",
            "svdFile": ".vscode/$MCU_SVD",
            "configFiles": [
                "$Prog_CFG",
                "$MCU_CFG"
            ],
            "preLaunchTask": "RUST: cargo build (release)"
        }
    ]
}
EOF

cat > .vscode/tasks.json << EOF
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "CPU: Build, Download and run",
            "type": "shell",
            "command": "/usr/bin/openocd",
            "args": [
                "-f",
                "$Prog_CFG",
                "-f",
                "$MCU_CFG",
                "-c",
                "program target/thumbv7m-none-eabi/release/$PRJ_N verify reset exit"
            ],
            "problemMatcher": [],
            "dependsOn": "RUST: cargo build (release)"
        },
        /*{
            "label": "CPU: Download and run",
            "type": "shell",
            "command": "/usr/bin/openocd",
            "args": [
                "-f",
                "$Prog_CFG",
                "-f",
                "$MCU_CFG",
                "-c",
                "program target/thumbv7m-none-eabi/release/$PRJ_N verify reset exit"
            ],
            "problemMatcher": []
        },*/
        {
            "label": "CPU: Reset and run",
            "type": "shell",
            "command": "/usr/bin/openocd",
            "args": [
                "-f",
                "$Prog_CFG",
                "-f",
                "$MCU_CFG",
                "-c init",
                "-c reset",
                "-c exit"
            ],
            "problemMatcher": []
        },
        /*{
            "label": "CPU: Stop",
            "type": "shell",
            "command": "/usr/bin/openocd",
            "args": [
                "-f",
                "$Prog_CFG",
                "-f",
                "$MCU_CFG",
                "-c init",
                "-c halt",
                "-c exit"
            ],
            "problemMatcher": []
        },
        {
            "label": "CPU: Run",
            "type": "shell",
            "command": "/usr/bin/openocd",
            "args": [
                "-f",
                "$Prog_CFG",
                "-f",
                "$MCU_CFG",
                "-c init",
                "-c resume",
                "-c exit"
            ],
            "problemMatcher": []
        },*/
        {
            "label": "CPU: Build to BIN",
            "type": "shell",
            "command": "cargo",
            "args": [
                "objcopy",
                "--bin",
                "$PRJ_N",
                "--target",
                "thumbv7m-none-eabi",
                "--release",
                "$PRJ_N.bin"
            ],
            "presentation": {
                "focus": true
            },
            "problemMatcher": [
             	"\$rustc"   
            ],
        },
        {
            "type": "shell",
            "command": "cargo",
            "args": [
                "build",
                "--release"
            ],
            "problemMatcher": [
             	"\$rustc"   
            ],
            "group": "build",
            "label": "RUST: cargo build (release)"
        },
        {
            "type": "cargo",
            "subcommand": "clean",
            "problemMatcher": [
             	"\$rustc"   
            ],
            "label": "RUST: cargo clean"
        },
        {
            "type": "cargo",
            "subcommand": "check",
            "problemMatcher": [
             	"\$rustc"   
            ],
            "group": "build",
            "label": "RUST: cargo check"
        },
        {
            "type": "shell",
            "command": "cargo",
            "args": [
                "fmt"
            ],
            "problemMatcher": [
             	"\$rustc"   
            ],
            "label": "RUST: Format code"
        }
    ]
}
EOF

#базовый код для проверки проекта, моргание светодиодом
cat > src/main.rs << EOF
#![deny(unsafe_code)]
#![no_std]
#![no_main]

use panic_halt as _;

use nb::block;

use cortex_m_rt::entry;
use embedded_hal::digital::v2::OutputPin;
use stm32${Series_N}xx_hal::{pac, prelude::*, timer::Timer};

// Определяем входную функцию.
#[entry]
fn main() -> ! {
    // Получаем управление над аппаратными средствами
    let cp = cortex_m::Peripherals::take().unwrap();
    let dp = pac::Peripherals::take().unwrap();
    let mut flash = dp.FLASH.constrain();
    let mut rcc = dp.RCC.constrain();

    let clocks = rcc.cfgr.freeze(&mut flash.acr);
    let mut gpioc = dp.GPIOC.split(&mut rcc.apb2);

    // Конфигурируем пин c13 как двухтактный выход.
    // Регистр "crh" передаётся в функцию для настройки порта.
    // Для пинов 0-7, необходимо передавать регистр "crl".
    let mut led = gpioc.pc13.into_push_pull_output(&mut gpioc.crh);
    // Конфигурируем системный таймер на запуск обновления каждую секунду.
    let mut timer = Timer::syst(cp.SYST, &clocks).start_count_down(1.hz());

    // Ждём пока таймер запустит обновление
    // и изменит состояние светодиода.
    loop {
        block!(timer.wait()).unwrap();
        led.set_high().unwrap();
        block!(timer.wait()).unwrap();
        led.set_low().unwrap();
    }
}

EOF

echo "Good luck ^_^"
