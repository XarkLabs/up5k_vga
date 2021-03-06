# Makefile for icestorm tools + yosys + nextpnr
# Modified from examples in icestorm distribution
# 01-16-18 E. Brombaugh

# src directory
VPATH = ../src

SRC =	up5k_vga.v ../src/vga_6502.v ../src/ram_32kb.v \
		../src/acia.v ../src/acia_tx.v ../src/acia_rx.v \
		../src/vga.v ../src/vram_32kb.v ../src/rom_cg_2kB.v \
		../src/system_bus.v ../src/wishbone.v ../src/led_pwm.v \
		../src/ps2.v ../src/ps2_tx.v ../src/ps2_rx.v ../src/ps2_decode.v \
		../src/snd.v \
        ../verilog-6502/cpu_65c02.v ../verilog-6502/ALU.v

# preparing the machine code
FAKE_HEX =	rom.hex
REAL_HEX =  code.hex

# project stuff
PROJ = up5k_vga
PIN_DEF = icebreaker.pcf
SDC = up5k_vga.sdc
DEVICE = up5k

YOSYS = /usr/local/bin/yosys
NEXTPNR = nextpnr-ice40
NEXTPNR_ARGS = --pre-pack $(SDC) --placer heap
ICEPACK = icepack
ICETIME = icetime
ICEPROG = iceprog
ICEBRAM = icebram
CDCPROG = cdc_prog
VERILATOR = verilator
TECH_LIB = /usr/local/share/yosys/ice40/cells_sim.v
HEXDUMP = hexdump
HEXDUMP_ARGS = -v -e '1/1 "%02x " "\n"'

all: $(PROJ).bin

$(FAKE_HEX):
	$(ICEBRAM) -g 8 2048 > $(FAKE_HEX)

%.json: $(SRC) $(FAKE_HEX) ../src/chargen_2k.hex
	$(YOSYS) -p 'synth_ice40 -dsp -top $(PROJ) -json $@' $(SRC)

%.asc: %.json $(PIN_DEF) 
	$(NEXTPNR) --timing-allow-fail $(NEXTPNR_ARGS) --$(DEVICE) --json $< --pcf $(PIN_DEF) --asc $@

$(REAL_HEX): ../cc65/Makefile ../cc65/sbc.cfg $(wildcard ../cc65/*.inc) $(wildcard ../cc65/*.s)
	$(MAKE) -C ../cc65/
	cp ../cc65/$(FAKE_HEX) ./$(REAL_HEX)
		
%.bin: %.asc $(REAL_HEX)
	$(ICEBRAM) $(FAKE_HEX) $(REAL_HEX) < $< > temp.asc
	$(ICEPACK) temp.asc $@

%.rpt: %.asc
	$(ICETIME) -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bin
	$(CDCPROG) -p /dev/ttyACM0 $<

recode:
	rm -f $(REAL_HEX) $(PROJ).bin
	$(MAKE) prog
	
icebprog: $(PROJ).bin
	$(ICEPROG) $(PROJ).bin
	
icebroms:
	$(ICEPROG) $(PROJ).bin
	$(ICEPROG) -o 0x40000 osibasic.rom

icebdemos:
	$(MAKE) -C ../demos
	$(ICEPROG) -o 0x50000 ../demos/basic_programs.rom

icebprogall: icebprog icebroms icebdemos

icebextract:
	$(ICEPROG) -R655360 -o 0x50000 ../demos/extracted_programs.rom
	$(MAKE) -C ../demos extract
    
flash: $(PROJ).bin
	$(CDCPROG) -w -p /dev/ttyACM0 $<

lint: $(SRC)
	$(VERILATOR) --lint-only -Wall --top-module $(PROJ) $(TECH_LIB) $(SRC)

clean:
	$(MAKE) -C ../cc65/ clean
	rm -f *.json *.asc *.rpt *.bin *.hex

.SECONDARY:
.PHONY: all prog clean
