// up5k_vga.v - top level for vga in up5k
// 05-02-19 E. Brombaugh
// 07-04-19 Xark (for IceBreaker)

`default_nettype none

module up5k_vga(
	// 16MHz clock osc
	input clk_12,	// 12 Mhz clock on IceBreaker
	
	// Reset input
	input NRST,
	
	// vga
	output [1:0] vga_r, vga_g, vga_b,
	output vga_vs, vga_hs,
    
	// serial
    	inout RX, TX,
	
	// sigma-delta audio
// TODO:	output	audio_nmute,
// TODO:			audio_l,
// TODO:			audio_r,
	
	// SPI0 port
	inout	spi0_mosi,
			spi0_miso,
			spi0_sclk,
			spi0_cs0,
	
	// PS/2 keyboard port
	inout	ps2_clk,
			ps2_dat,
	
	// gpio
    //input [3:0] pmod,
	
	// LED - via drivers
	output RGB0, RGB1, RGB2,

	// IceBreaker board LEDs (red = booted, green = PS/2 diagnostics)
	output LEDR_N, LEDG_N,

	// IceBreaker built in PMOD2 LEDs and buttons (gpio)
	output LED1, LED2, LED3, LED4, LED5,
	input BTN1, BTN2, BTN3
);
	
	// NOTE: PLL 12Mhz -> 40Mhz not exact, but 39.75Mhz is "close enough" for monitors tested
	// Fin=12, Fout=39.75 (12*(52/16))
	wire clk_4x, pll_lock;
	SB_PLL40_PAD #(
		.DIVR(4'b0000),		// DIVR =  0
		.DIVF(7'b0110100),	// DIVF = 52
		.DIVQ(3'b100),		// DIVQ =  4
		.FILTER_RANGE(3'b001),
		.FEEDBACK_PATH("SIMPLE"),
		.DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
		.FDA_FEEDBACK(4'b0000),
		.DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
		.FDA_RELATIVE(4'b0000),
		.SHIFTREG_DIV_MODE(2'b00),
		.PLLOUT_SELECT("GENCLK"),
		.ENABLE_ICEGATE(1'b0)
	)
	pll_inst (
		.PACKAGEPIN(clk_12),
		.PLLOUTCORE(clk_4x),
		.PLLOUTGLOBAL(),
		.EXTFEEDBACK(),
		.DYNAMICDELAY(8'h00),
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.LATCHINPUTVALUE(),
		.LOCK(pll_lock),
		.SDI(),
		.SDO(),
		.SCLK()
	);
	
	// generate 2x, 1x clocks from 4x clk
	reg clk_2x, clk;
	always @(posedge clk_4x)
		{clk,clk_2x} <= {clk,clk_2x} + 2'b01;
	
	// external reset debounce
	reg [7:0] ercnt;
	reg erst;
	always @(posedge clk)
	begin
		if(NRST == 1'b0)
		begin
			ercnt <= 8'h00;
			erst <= 1'b1;
		end
		else
		begin
			if(!&ercnt)
				ercnt <= ercnt + 8'h01;
			else
				erst <= 1'b0;
		end
	end
	
	// reset generator waits > 10us
	reg [7:0] reset_cnt;
	reg reset;    
	always @(posedge clk)
	begin
		if(!pll_lock)
		begin
			reset_cnt <= 8'h00;
			reset <= 1'b1;
		end
		else
		begin
			if(reset_cnt != 8'hff)
			begin
				reset_cnt <= reset_cnt + 8'h01;
				reset <= 1'b1;
			end
			else
				reset <= erst;
		end
	end
	
	// system core
	wire [3:0] tst;
	wire [2:0] gpio_o;
	wire raw_rx, raw_tx;
	vga_6502 uut(
		.clk(clk),
		.clk_4x(clk_4x),
		.reset(reset),
    
		.vga_r(vga_r),
		.vga_g(vga_g),
		.vga_b(vga_b),
		.vga_vs(vga_vs),
		.vga_hs(vga_hs),
		
		.gpio_o({gpio_o, LED5, LED4, LED3, LED2, LED1}),
		.gpio_i({5'b000000, BTN3, BTN2, BTN1}),
    
        .RX(raw_rx),
        .TX(raw_tx),
	
// TODO:	.snd_nmute(audio_nmute),
// TODO:	.snd_l(audio_l),
// TODO:	.snd_r(audio_r),
	
		.spi0_mosi(spi0_mosi),
		.spi0_miso(spi0_miso),
		.spi0_sclk(spi0_sclk),
		.spi0_cs0(spi0_cs0),
	
		.ps2_clk(ps2_clk),
		.ps2_dat(ps2_dat),
		
		.rgb0(RGB0),
		.rgb1(RGB1),
		.rgb2(RGB2),
    
		.tst(tst)
	);
	
	// Serial I/O w/ pullup on RX
	SB_IO #(
		.PIN_TYPE(6'b101001),
		.PULLUP(1'b1),
		.NEG_TRIGGER(1'b0),
		.IO_STANDARD("SB_LVCMOS")
	) urx_io (
		.PACKAGE_PIN(RX),
		.LATCH_INPUT_VALUE(1'b0),
		.CLOCK_ENABLE(1'b0),
		.INPUT_CLK(1'b0),
		.OUTPUT_CLK(1'b0),
		.OUTPUT_ENABLE(1'b0),
		.D_OUT_0(1'b0),
		.D_OUT_1(1'b0),
		.D_IN_0(raw_rx),
		.D_IN_1()
	);
	SB_IO #(
		.PIN_TYPE(6'b101001),
		.PULLUP(1'b0),
		.NEG_TRIGGER(1'b0),
		.IO_STANDARD("SB_LVCMOS")
	) utx_io (
		.PACKAGE_PIN(TX),
		.LATCH_INPUT_VALUE(1'b0),
		.CLOCK_ENABLE(1'b0),
		.INPUT_CLK(1'b0),
		.OUTPUT_CLK(1'b0),
		.OUTPUT_ENABLE(1'b1),
		.D_OUT_0(raw_tx),
		.D_OUT_1(1'b0),
		.D_IN_0(),
		.D_IN_1()
	);
	
	// Turn on IceBreaker RED led
	assign LEDR_N = 1'b0;
	assign LEDG_N = ~(tst[3]|tst[2]|tst[1]|tst[0]); 

endmodule
