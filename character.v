module character 
	(
		clock,
		x,
		y,
		colour,
		enable,
		KEY,
		
		x_store,
		y_store,
		
		duckr
	);

	input clock, enable;
	input [3:0] KEY;
	
	wire jump, duck, left, right;
	
	assign right = ~KEY[0];
	assign jump = ~KEY[1];
	assign duck = ~KEY[2];
	assign left = ~KEY[3];
	
	output reg duckr = 0;
	
	output reg [7:0] x;
	output reg [6:0] y;
	output reg [2:0] colour = 4;

	output reg [7:0] x_store = 10;
	output reg [6:0] y_store = 50;

	reg key_signal = 0, key_old = 0;
	reg old = 0;
	reg [6:0] counter = 0;
	reg [6:0] go_up = 0;
	
	reg [6:0] slowercounter = 0;
	reg [6:0] speedoffset;
	
	wire [2:0] colour_temp;
	dino_ram(
		.address(counter[5:0]),
		.q(colour_temp),
		.wren(0),
		.clock(clock)
	);
	
	always @(*) begin
		case(slowercounter)
			0: speedoffset = -4;
			1: speedoffset = -3;
			2: speedoffset = -2;
			3: speedoffset = -2;
			4: speedoffset = -1;
			5: speedoffset = -1;
			6: speedoffset = -1;
			7: speedoffset = -1;
			8: speedoffset = -1;
			12: speedoffset = -1;
			13: speedoffset = -1;
			14: speedoffset = -1;
			15: speedoffset = -1;
			16: speedoffset = -1;
			17: speedoffset = -2;
			18: speedoffset = -2;
			19: speedoffset = -3;
			20: speedoffset = -4;
			default: speedoffset = 0;
		endcase
	end
	
	wire [6:0] offset;
	assign offset[6:0] = go_up > 7'd16 ? go_up - 7'd16 : 7'd16 - go_up;
	
	always @(posedge clock) 
	begin
		
		if (~old & enable) begin
			counter <= 0;
		end
		old <= enable;
		
		if (enable) 
		begin
			key_signal <= jump;

			if (counter < 64) 
			begin
				colour <= 0;	
			end
			else
			begin
				colour <= colour_temp;	
			end
			
			if (counter == 64) begin
				duckr <= duck & ~jump;
				
				if (left & x_store > 0) 
					x_store <= x_store - 1;
				else if (right & x_store < 156)
					x_store <= x_store + 1;
			
				if (key_signal && (go_up == 0)) begin
					go_up <= 32;
					slowercounter <= 0;
				end
				else if (go_up > 0) begin
					go_up <= go_up + speedoffset;
					slowercounter <= slowercounter + 1;
				end
				
				y_store <= 35 + offset;
			end
			
			counter <= counter + 1;
		end		
	end

	always @(*) begin
		if (duckr) begin			
			x = x_store + 15 - counter[5:2];
			y = y_store + 12 + counter[1:0];
		end
		else begin
			x = x_store + counter[1:0];
			y = y_store + counter[5:2];
		end
	end

endmodule




