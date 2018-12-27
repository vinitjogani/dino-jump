module main
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,
		SW,
		HEX0,
		HEX1,
		HEX4, 
		HEX5,
		LEDR,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		PS2_CLK,
		PS2_DAT
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX4, HEX5;
	
	inout				PS2_CLK;
	inout				PS2_DAT;
	
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = SW[1];
	
	wire reset_game;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire [3:0] KEYBOARD;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		
		defparam VGA.BACKGROUND_IMAGE = "bg.mif";
			

    // Instansiate datapath
	wire [7:0] score;
	wire [7:0] high_score;
	controller c0(
		.clock(CLOCK_50),
		.out_plot(writeEn),
		.out_colour(colour),
		.out_x(x),
		.out_y(y),
		.score(score),
		.high_score(high_score),
		.KEY(~KEYBOARD),
		.pause(SW[9]),
		.resetn(~reset_game)
	);
	
	hex_decoder h0 (
		.hex_digit(score[3:0]),
		.segments(HEX0)
	);
	
	hex_decoder h1 (
		.hex_digit(score[7:4]),
		.segments(HEX1)
	);
	
	hex_decoder h2 (
		.hex_digit(high_score[3:0]),
		.segments(HEX4)
	);
	
	hex_decoder h3 (
		.hex_digit(high_score[7:4]),
		.segments(HEX5)
	);
	
	
	
	
	keyboard_tracker #(.PULSE_OR_HOLD(0)) k0 (
    .clock(CLOCK_50),
	 .reset(1),
	 
	 .PS2_CLK(PS2_CLK),
	 .PS2_DAT(PS2_DAT),
	 
	 .w(KEYBOARD[1]), 
	 .a(KEYBOARD[3]), 
	 .s(KEYBOARD[2]), 
	 .d(KEYBOARD[0]),
	 
	 .space(reset_game)

	 );
	
	
	
	
	reg [23:0] tone = 1; 
	always @(posedge KEY[0]) begin
		tone <= tone << 1;
	end
	

endmodule
