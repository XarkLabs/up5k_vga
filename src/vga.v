// vga.v - vga drive logic
// this generates a VESA 800x600 64-color display w/ 40MHz pixel clock
// 05-08-19 E. Brombaugh

`default_nettype none

module vga(
	input clk,					// 10MHz cpu clock
	input clk_4x,				// 40MHz pixel clock
	input reset,				// active high system reset
	input sel_ram,				// decoded video RAM address
	input sel_ctl,				// decoded video control address
	input we,					// write enable
	input [12:0] addr,			// address (8k range)
	input [7:0] din,			// write data
	output reg [7:0] ram_dout,	// RAM read data
	output reg [7:0] ctl_dout,	// control read data
	output reg [1:0]	vga_r,	// 2-bit red data
						vga_g,	// 2-bit green data
						vga_b,	// 2-bit blue data
	output reg 			vga_vs,	// vertical sync
						vga_hs,	// horizontal sync
	output reg			vga_int	// vsync interrupt
);
	// set up timing parameters for 16MHz clock rate
	localparam MAX_H = 1055;	// 1056 clocks/line
	localparam HFP_WID = 40;	// 40 clocks H Front Porch
	localparam HS_WID = 128;	// 128 clocks H sync pulse
	localparam HBP_WID = 88;	// 88 clocks H Back Porch
	localparam HA_WID = 800;	// 800 clocks horizontal active
	localparam MAX_V = 627;		// 628 lines/frame
	localparam VFP_WID = 1;		// 1 line V Front Porch
	localparam VS_WID = 4;		// 3 lines V sync pulse
	localparam VBP_WID = 23;	// 41 lines V Back Porch
	localparam VA_WID = 600;	// 600 lines vertical active

	// control register and color LUT
	reg [5:0] color_lut[15:0];
	reg [7:0] ctrl, hires;
	reg	intr, intr_en;
	// write
	always @(posedge clk)
		if(reset)
		begin
			// clear control reg
			ctrl <= 8'h00;

			// clear interrupt flag and enable
			intr <= 1'b0;
			intr_en <= 1'b0;

			// hires color mapping
			hires <= 8'hF3;
			
			// 3-bits luma, 3-bits chroma phase, 2-bits chroma gain
			color_lut[0]  <= 6'b00_00_00;	// black
			color_lut[1]  <= 6'b10_00_00;	// red
			color_lut[2]  <= 6'b00_10_00;	// green
			color_lut[3]  <= 6'b00_00_10;	// blue
			color_lut[4]  <= 6'b00_10_10;	// cyan
			color_lut[5]  <= 6'b10_00_10;	// magenta
			color_lut[6]  <= 6'b10_10_00;	// yellow
			color_lut[7]  <= 6'b01_01_01;	// dk gray
			color_lut[8]  <= 6'b10_10_10;	// lt gray
			color_lut[9]  <= 6'b11_10_11;	// pink
			color_lut[10] <= 6'b11_10_00;	// lt org
			color_lut[11] <= 6'b11_11_10;	// lt yellow
			color_lut[12] <= 6'b00_11_10;	// lt green
			color_lut[13] <= 6'b00_10_11;	// lt blue
			color_lut[14] <= 6'b11_01_11;	// lt purple
			color_lut[15] <= 6'b11_11_11;	// white
		end
		else
		begin
			if((we == 1'b1) && (sel_ctl == 1'b1))
			begin
				if(addr[4]==1'b0)
					case(addr[3:0])
						4'h0: ctrl <= din;
						4'h1: hires <= din;
						4'h2: {intr_en, intr} <= { din[7], 1'b0 };
					endcase
				else
					color_lut[addr[3:0]] <= din[5:0];
			end

			if(intr_stb)
				intr <= 1'b1;
		end
		
	// read
	always @(posedge clk)
		if((we == 1'b0) && (sel_ctl == 1'b1))
			if(addr[4]==1'b0)
				case(addr[3:0])
					4'h0: ctl_dout <= ctrl;
					4'h1: ctl_dout <= hires;
					4'h2: ctl_dout <= {intr & intr_en, 6'b000000, intr_en};
					default: ctl_dout <= 8'h00;
				endcase
			else
				ctl_dout <= {2'b00,color_lut[addr[3:0]]};

	// break out bank select for glyph / color addressing
	wire gc = ctrl[0];
	wire bank = ctrl[1];
	wire [1:0] mode = ctrl[3:2];

	// video timing - separate H and V counters
	reg [10:0] hcnt;
	reg [9:0] vcnt;
	reg hs, vs, ha, va;
	reg intr_stb;
	always @(posedge clk_4x)
	begin
		if(reset)
		begin
			hcnt <= 11'd0;
			vcnt <= 10'd0;
			hs <= 1'b0;
			vs <= 1'b0;
			ha <= 1'b0;
			va <= 1'b0;
			intr_stb <= 1'b0;
		end
		else
		begin
			intr_stb <= 1'b0;
			// counters
			if(hcnt == MAX_H)
			begin
				// horizontal counter
				hcnt <= 11'd0;
				if(vcnt == MAX_V)
				begin
					vcnt <= 10'd0;
					intr_stb <= 1'b1;
				end
				else
					vcnt <= vcnt + 10'd1;
				
				// vertical sync
				if(vcnt == VFP_WID)
					vs <= 1'b1;
				else if(vcnt == (VFP_WID + VS_WID))
					vs <= 1'b0;
				
				// vertical active
				if(vcnt >= (VFP_WID + VS_WID + VBP_WID))
					va <= 1'b1;
				else
					va <= 1'b0;
			end
			else
				hcnt <= hcnt + 1;

			// horizontal sync
			if(hcnt == HFP_WID)
				hs <= 1'b1;
			else if(hcnt == (HFP_WID + HS_WID))
				hs <= 1'b0;
			
			// horizontal active
			if(hcnt >= (HFP_WID + HS_WID + HBP_WID))
				ha <= 1'b1;
			else
				ha <= 1'b0;
		end
	end

	// character generator
	localparam ASTART = HFP_WID + HS_WID + HBP_WID;	// start of active area
	localparam BK_TOP = VFP_WID + VS_WID + VBP_WID; // vertical top
	
	// extract video character data address & ROM line
	reg active;			// active video
	reg [2:0] pcnt;		// pixel/char count
	reg vload;			// load video shift reg
	reg hrena;			// hi-res shift enable at 1/2 pixel rate
	reg mrena;			// med-res shift enable at 1/4 pixel rate
	reg [6:0] haddr;	// horizontal component of vram addr
	reg [2:0] cline;	// character line index
	reg [6:0] vaddr;	// vertical component of vram addr
	always @(posedge clk_4x)
	begin
		if(reset)
		begin
			active <= 1'b0;
			pcnt <= 3'b000;
			vload <= 1'b0;
			hrena <= 1'b0;
			mrena <= 1'b0;
			haddr <= 7'd0;
			cline <= 3'b000;
			vaddr <= 7'd0;
		end
		else
		begin
			// wait for start of active
			if(active == 1'b0)
			begin
				if((hcnt == ASTART) && (vcnt >= BK_TOP))
				begin
					// reset horizontal stuff at hcnt == ASTART
					active <= 1'b1;		// active video
					pcnt <= 3'b000;
					vload <= 1'b1;		// start with load
					hrena <= 1'b1;		// enable on 1st
					mrena <= 1'b1;		// enable on 1st
					haddr <= 7'd0;
				end
				
				// reset vertical stuff at vcnt == 0;
				if(vcnt == 0)
				begin
					cline <= 3'b000;
					vaddr <= 7'd0;
				end
			end
			else
			begin
				if(pcnt == 3'b111)
				begin
					// generate vload
					vload <= 1'b1;
					
					// end of line?
					if(haddr == 7'd99)
					begin
						// shut off counting & loading
						active <= 1'b0;
						vload <= 1'b0;
						
						// time to update vertical address?
						if(cline == 3'b111)
							vaddr <= vaddr + 7'd1;
						
						// update character line index
						cline <= cline + 3'b001;
					end
					
					// update horizontal address
					haddr <= haddr + 7'd1;
				end
				else
					vload <= 1'b0;
				
				// always increment pixel count
				pcnt <= pcnt + 3'b001;
				
				// hrena runs at 1/2 rate
				hrena <= pcnt[0];
				
				// mrena runs at 1/4 rate
				mrena <= &pcnt[1:0];
			end
		end
	end
	
	// pipeline control signals
	reg [2:0] vload_pipe;
	reg [2:0] hrena_pipe;
	reg [2:0] mrena_pipe;
	reg [4:0] active_pipe, hs_pipe, vs_pipe;
	reg [2:0] cline_dly0, cline_dly1;
	always @(posedge clk_4x)
	begin
		vload_pipe <= {vload_pipe[1:0],vload};
		hrena_pipe <= {hrena_pipe[1:0],hrena};
		mrena_pipe <= {mrena_pipe[1:0],mrena};
		active_pipe <= {active_pipe[3:0],active};
		hs_pipe <= {hs_pipe[3:0],hs};
		vs_pipe <= {vs_pipe[3:0],vs};
		cline_dly0 <= cline;
		cline_dly1 <= cline_dly0;
	end
	wire vload_dly = vload_pipe[2];
	wire hrena_dly = hrena_pipe[2];
	wire mrena_dly = mrena_pipe[2];
	wire active_dly = active_pipe[4];
	wire hs_dly = hs_pipe[4];
	wire vs_dly = vs_pipe[4];
	wire [2:0] cline_dly = cline_dly1;
	
	// one pipe delay

	// mult/add horizontal and vertical addresses to make vram address
	reg [12:0] char_addr;
	always @(posedge clk_4x)
		char_addr <= vaddr*100 + haddr;
	
	// shift up for glyph + color
	wire [13:0] vid_addr = {char_addr, 1'b0};
	
	// sync 1/4 rate to vload for cpu access
	reg [1:0] scnt;
	reg cpu_mux, cpu_mux_d1;
	always @(posedge clk_4x)
		if(reset)
		begin
			scnt <= 2'b10;
			cpu_mux <= 1'b0;
			cpu_mux_d1 <= 1'b0;
		end
		else
		begin
			if(vload)
				scnt <= 2'b00;
			else
				scnt <= scnt + 2'b01;
			
			// mux timed to allow CPU access ~1/2 way thru low rate cycle
			cpu_mux <= (scnt == 2'b00) ? 1'b1 : 1'b0;
			cpu_mux_d1 <= cpu_mux;
		end
	
	// invert msb of cpu addr due to decoding on D/E range
	wire [13:0] cpu_addr = {~addr[12],addr[11:0],gc};
		
	// address mux selects video only for now
	wire [13:0] mem_addr = cpu_mux ? cpu_addr: vid_addr;
		
	// cpu writes to video memory only on 2nd half of CPU clock cycle
	wire mem_we = sel_ram & we & cpu_mux;
	
	// instantiated video memory
	wire [7:0] raw_ram_dout;
	wire [15:0] raw_ram_word;
	vram_32kb uram(
		.clk(clk_4x),
		.we(mem_we),
		.addr({bank,mem_addr}),
		.din(din),
		.dout_byte(raw_ram_dout),
		.dout_word(raw_ram_word)
	);

	// hold data for full cycle for CPU
	always @(posedge clk_4x)
		if(cpu_mux_d1)
			ram_dout <= raw_ram_dout;
		
	// two pipe delay
	
	// Character Generator ROM
	wire [10:0] cg_addr = {raw_ram_word[7:0],cline_dly};
	wire [7:0] cg_dout;
	rom_cg_2kB ucgr(
		.clk(clk_4x),
		.addr(cg_addr),
		.dout(cg_dout)
	);
	
	// pipeline character color data
	reg [7:0] color_idx;
	always @(posedge clk_4x)
		color_idx <= raw_ram_word[15:8];
	
	// hires 2-color graphics mode nybble select
	reg [3:0] hr_dout;
	always @(posedge clk_4x)
		case(cline_dly[2:1])
			2'b00: hr_dout <= raw_ram_word[3:0];
			2'b01: hr_dout <= raw_ram_word[7:4];
			2'b10: hr_dout <= raw_ram_word[11:8];
			2'b11: hr_dout <= raw_ram_word[15:12];
		endcase
	
	// medres 16-color select
	reg [7:0] mr_dout;
	always @(posedge clk_4x)
		mr_dout <= cline_dly[2] ? raw_ram_word[15:8] : raw_ram_word[7:0];
	
	// three pipes delay
		
	// Video Shift Register for character mode
	reg [7:0] vid_shf_reg;
	reg [3:0] fore, back;
	always @(posedge clk_4x)
		if(vload_dly)
		begin
			vid_shf_reg <= cg_dout;
			fore <= color_idx[7:4];
			back <= color_idx[3:0];
		end
		else 
			vid_shf_reg <= {vid_shf_reg[6:0],1'b0};
		
	// Video Shift Register for hires mode runs at 1/2 pixel rate
	reg [3:0] hr_shf_reg;
	always @(posedge clk_4x)
		if(hrena_dly)
		begin
			if(vload_dly)
				hr_shf_reg <= hr_dout;
			else 
				hr_shf_reg <= {hr_shf_reg[2:0],1'b0};
		end
	
	// Selector for medres mode
	reg [3:0] mr_sel_reg;
	always @(posedge clk_4x)
		if(mrena_dly)
			if(vload_dly)
				mr_sel_reg <= mr_dout[3:0];
			else
				mr_sel_reg <= mr_dout[7:4];
	
	// four pipes delay
		
	// color LUT addr
	reg [3:0] color_addr;
	always @(*)
		case(mode)
			2'b00: color_addr = vid_shf_reg[7] ? fore : back;
			2'b01: color_addr = hr_shf_reg[3] ? hires[7:4] : hires[3:0];
			2'b10: color_addr = mr_sel_reg;
			2'b11: color_addr = mr_sel_reg;
		endcase
		
	// Get color
	reg [1:0] r, g, b;
	always @(posedge clk_4x)
		{r, g, b} <= color_lut[color_addr];
		
	// reclock outputs
	always @(posedge clk_4x)
	begin
		vga_r <= active_dly ? r : 2'd0;
		vga_g <= active_dly ? g : 2'd0;
		vga_b <= active_dly ? b : 2'd0;
		vga_hs <= hs_dly;
		vga_vs <= vs_dly;
		vga_int <= (intr & intr_en);
	end
endmodule
