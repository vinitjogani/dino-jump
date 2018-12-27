module block 
	(
		clock,
		startx,
		reset,
		x,
		y,
		colour,
		enable,
		increment,
		speed
	);

	input clock, enable, reset;
	input [7:0] startx;
	input [1:0] speed;
	
	output [7:0] x;
	output [6:0] y;
	output reg [2:0] colour;
	output reg increment;

	reg [7:0] x_store;
	reg [6:0] y_store = 58;
	
	reg first_time = 1;
	reg old = 0;
	reg [6:0] counter = 0;

	wire [1:0] location;
	wire [7:0] skip_frames;
	
	lfsr l1 (.clock(clock), .seed(startx), .out(location[0]));
	lfsr l2 (.clock(clock), .seed(startx[7:4]), .out(location[1]));
	lfsr8bit l0 (.clock(clock), .seed(startx), .out(skip_frames));
	
	reg [7:0] not_draw = 0;
	
	
	always @(posedge clock) 
	begin
		if (first_time) begin
			x_store <= startx;
			first_time <= 0;
		end 		
		
		increment <= 0;
		
		if (~old & enable) begin
			counter <= 0;
		end
		old <= enable;
		
		if (enable) 
		begin
			if (counter < 64 | ~reset) 
			begin
				colour <= 0;	
			end
			else
			begin
				colour <= 7;	
			end

			if (counter == 64) 
			begin
				if (~reset) begin					
					x_store <= startx;
				end
				else begin
					if (x_store == 0) begin
						x_store <= 158;
						
						increment <= 1;
						
						not_draw <= skip_frames;
						
						if(location == 0) 
							y_store <= 58;
						else if(location == 1) 
							y_store <= 50;
						else if(location == 2) 
							y_store <= 42;
						else 
							y_store <= 34;
							
					end
					else if (not_draw == 0) begin
						x_store <= x_store - speed;
					end
				end
				
				if (not_draw != 0)
					not_draw <= not_draw - 1;
			end
			
			
			if (not_draw != 0)
				colour <= 0;
			
			counter <= counter + 1;
		end		
	end

	assign x = x_store + counter[1:0];
	assign y = y_store + counter[4:2];

endmodule
