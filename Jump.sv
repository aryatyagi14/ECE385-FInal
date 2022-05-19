module jump (	input Clk, Reset, Run, Left, Right,//Run = 1'b1 when W key is pressed
					input logic signed [20:0] BallY, BallX,
					input logic signed [20:0] Ground_Y, Ceiling_Y, Left_X, Right_X,
						output logic signed[20:0] Ball_Y_Motion, Ball_X_Motion);
						
		enum logic [2:0] {Wait, Jump, Air, End } curr_state, next_state; // States curr_state,
		
		logic [20:0] gravity = 10'd1;
		
		initial begin 
			Ball_Y_Motion = 0;
		end
		
		always_ff @ (posedge Clk or posedge Reset) 
		begin
				if (Reset)
					curr_state = Wait; 
				else
					curr_state = next_state;
		end
		
		// Assign outputs based on ‘state’
		always_comb
		begin
		// Default to be self-looping 		
				next_state = curr_state; 
				
				unique case (curr_state) //based on current state we set the next state
						Wait : begin
							if (Run) begin
								next_state = Jump;
							end		
						end
											
						Jump :  begin
							next_state = Air;
						end
								
						Air : 	begin
							if ((BallY + Ball_Y_Motion) > Ground_Y ) begin //chnage when I have thing to collide to 
								next_state = End;
							end
						end
							
						End : begin
							if (~Run) begin
									next_state = Wait;
							end
						end
				endcase
		end
		// Assign outputs based on ‘state’
		always_ff @ (posedge Clk) begin
		
			if (Left & (BallX - 2 > Left_X)) 
				Ball_X_Motion <= -2;
			else if (Right & (BallX + 32 + 2 < Right_X)) 
				Ball_X_Motion <= 2;
			else 
				Ball_X_Motion <= 0;
				
			case (curr_state)
					Wait: begin
						state <= 1'd0;
						if (BallY + 1 < Ground_Y) begin
							Ball_Y_Motion <= Ball_Y_Motion + gravity;
						end
						else begin 
							Ball_Y_Motion <= 0;
						end
						
					end
					
					Jump: begin
						state <= 1'd1;
						Ball_Y_Motion <= -16;
					end 
						
					Air: begin
						state <= 1'd2;
						if (BallY > Ceiling_Y ) begin 
							Ball_Y_Motion <= Ball_Y_Motion + gravity;
						end
						else begin 
							Ball_Y_Motion <= 0;
						end
						
					end
				
					End: begin
							state <= 1'd3;
							Ball_Y_Motion <= 0;
					end
			endcase
		end
		
endmodule
