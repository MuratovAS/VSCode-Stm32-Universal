# itmdump

## Description

Simple utility to parse and dump ARM Cortex-M SWO trace output. It is modified version of [OpenOCD](http://openocd.org/) `contrib/itmdump.c`. Changes were done special for using with QtCreator as an External Tool.

- All messages redirected to sdterr
- Char-by-char out replaced with buffered out

## Example of use

Print only strings captured:

```
./tools/itmdump/itmdump -f ../build/swv.log -d1
```

where `file` can be a regular file, named pipe or VCP (e.g. /dev/ttyUSB1). Remove `-d1` argument to print raw ITM messages.

# uartdump

## Description

Simple utility to parse and dump serial output, special for using with QtCreator as an External Tool.

## Example of use

Print strings from /dev/ttyUSB0:

```
uartdump -f /dev/ttyUSB0 -b 115200
```

# URL

https://habr.com/en/post/440024/

https://github.com/esynr3z/openocd-stuff/tree/master/tools

# 