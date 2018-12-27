module controller(
	clock,
	out_x, out_y, out_colour, out_plot,
	score, high_score, KEY, pause, resetn
);

	input clock, pause, resetn;
	input [3:0] KEY;

	output reg [7:0] out_x;
	output reg [6:0] out_y;
	output reg [2:0] out_colour;
	output reg out_plot;
	output reg [7:0] score = 0, high_score = 0;
	
	reg [20:0] counter = 0;
	reg [2:0] enable;
	reg enable_character;
	reg enable_f;
	wire [2:0] increment;	
	reg [1:0] game_over = 0;
	reg reset = 0;
	
	wire [7:0] x0, x1, x2, cx, fx;
	wire [6:0] y0, y1, y2, cy, fy;
	wire [2:0] colour0, colour1, colour2, colourc, fc;
	
	wire duckr;
	wire [7:0] minx, maxx;
	wire [6:0] miny, real_miny, maxy;
	
	assign real_miny = duckr ? miny + 12 : miny;
	assign maxx = duckr ? minx + 16 : minx + 4;
	assign maxy = duckr ? miny + 12 + 4 : miny + 16;
	
	
	reg [1:0] speed;	
	always @(*) begin
		if (score > 10) 
			speed = 3;
		else if (score > 5)
			speed = 2;
		else 
			speed = 1;
	end
	
	paint_fail f1 (
		.clock(clock),
		.x(fx),
		.y(fy),
		.colour(fc),
		.game_over(game_over == 3)
	);
	
	block b0 (
		.clock(clock),
		.x(x0),
		.y(y0),
		.startx(148),
		.colour(colour0),
		.enable(enable[0]),
		.reset(resetn & ~game_over),
		.increment(increment[0]),
		.speed(speed)
	);
	
	
	block b1 (
		.clock(clock),
		.x(x1),
		.y(y1),
		.colour(colour1),
		.startx(108),
		.enable(enable[1]),
		.reset(resetn & ~game_over),
		.increment(increment[1]),
		.speed(speed)
	);
	
	block b2 (
		.clock(clock),
		.x(x2),
		.y(y2),
		.colour(colour2),
		.startx(128),
		.enable(enable[2]),
		.reset(resetn & ~game_over),
		.increment(increment[2]),
		.speed(speed)
	);
	
	character c0 (
		.clock(clock),
		.x(cx),
		.y(cy),
		.colour(colourc),
		.enable(enable_character),
		.KEY(KEY),
		.x_store(minx),
		.y_store(miny),
		.duckr(duckr)
	);
	
	always @(posedge clock) begin	
		reset <= reset & resetn;
		enable_character <= 0;
		
		out_plot <= 1;	
		if (~pause & (game_over != 3)) begin
					
			
			if (counter < 1024) begin
				enable <= 3'b000;
				out_x <= fx;
				out_y <= fy;
				out_colour <= 0;
			end
			else if (counter < 1024 + 128)  begin
				enable <= 3'b001;	
				
				out_x <= x0;
				out_y <= y0;
				out_colour <= colour0;
			end
			else if (counter < 1024 + 256) begin
				enable <= 3'b010;	
				
				out_x <= x1;
				out_y <= y1;
				out_colour <= colour1;
			end
			else if (counter < 1024 + 384) begin
				enable <= 3'b100;						
				out_x <= x2;
				out_y <= y2;
				out_colour <= colour2;
			end
			else if (counter < 1024 + 512) begin
				enable_character <= 1;
				out_x <= cx;
				out_y <= cy;
				out_colour <= colourc;
				enable <= 3'b000;
			end
			else begin
				out_plot <= 0;
				enable <= 3'b000;
			end
			
			if (enable != 0) begin
			
				if (out_x <= maxx && 
					out_x >= minx && 
					out_y <= maxy && 
					out_y >= real_miny 
					&& out_colour != 0) begin
					
					game_over <= 1;
					reset <= 0;
					
			 end
			end
				
				
			if (counter >= 833333) begin
				counter <= 0;
				
				if (game_over == 1)
					game_over <= 2;
				else if (game_over == 2) begin
					game_over <= 3;
				end
				
				if (~resetn) begin
					score <= 0;
				end
			end
			else if (increment != 0) begin
				score <= score + 1;
				if (score >= high_score) begin
					high_score <= score + 1;
				end
			end
			
			counter <= counter + 1;
		end
		else if (~resetn) begin
			game_over <= 0;
			score <= 0;
		end
		else begin
			// GAME OVER
			enable <= 3'b000;
			out_plot <= 0;
			
			if (~pause) begin
				out_plot <= 1;
				out_x <= fx;
				out_y <= fy;
				out_colour <= fc;
			end
		end
	end
		
	
endmodule
