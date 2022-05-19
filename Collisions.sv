module collision (	input VGA_Clk, frame_Clk, Reset, 
						input logic [1:0] char_signal,
						input logic [10:0] ball_on,
						input logic signed [20:0] BallY, BallX, Ball_Size,
						input logic [9:0] DrawX, DrawY,
						input logic signed [20:0] baseX,
						output logic signed[20:0] Ground_Y, Ceiling_Y, Right_X, Left_X,
						output fall, coin1, coin2, coin3); 
		//outputs the tallest Y position of ground under character
		//Ground_Y is the top left corner of box to not go into ground
		//Ceiling_Y is the bottom of the platform being hit 
		//Right_X is the closest position of a platform to the right (left side of the platform)
		//Left_X is the closest platform to the left (rightmost side )
		
		logic signed [20:0] store_tallest_ground = 21'd999;
		logic signed [20:0] store_smallest_ceiling = -100;
		logic signed [20:0] store_smallest_right = 21'd5000;
		logic signed [20:0] store_biggest_left = 21'd0;
		
		logic signed [20:0] counter = 0;
	
		
		logic new1, new2;
		
		//logic fall = 0;
		
		always_ff @ (posedge frame_Clk) 
		begin
		
				if (fall) begin
					Ground_Y <= 999; //should have the Y pos block should stop at (top left)
				end
				else begin 
					Ground_Y <= store_tallest_ground; 
				end
				Ceiling_Y <= store_smallest_ceiling;
				Right_X <= store_smallest_right;
				Left_X <= store_biggest_left;
				
		end
		
		
		always_ff @ (posedge VGA_Clk) begin
		
				if (Reset) begin 
						fall  <= 0;
						coin1 <= 0;
						coin2 <= 0;
						coin3 <= 0;
				end
				
				else begin 
					counter = counter + 1;
			
					//collision on bottom of character
					if ((DrawX + baseX >= BallX) && (DrawX + baseX < BallX + Ball_Size) && (DrawY > BallY + Ball_Size)) begin 
					
							if ( ( (ball_on == 2) || (ball_on == 8) ||
								(char_signal == 2'd0 && ball_on == 3) || (char_signal == 2'd1 && ball_on == 1))
									&& (DrawY < store_tallest_ground))  begin 
									store_tallest_ground <= DrawY - 32;
							end
							
							//if we are mario or luigi AND below us is a goomba set floor
							if ((ball_on == 4) && (char_signal == 2'd0 || char_signal == 2'd1)  && (DrawY < BallY + Ball_Size + 30)
								&& (DrawY < store_tallest_ground)) begin 
									store_tallest_ground <= DrawY - 32;
							end
							
							if (ball_on == 9 && (char_signal == 2'd0 || char_signal == 2'd1) && (DrawY < BallY + Ball_Size + 30 )) begin 
									coin1 <= 0;
							end
							
							if (ball_on == 10 && (char_signal == 2'd0 || char_signal == 2'd1) && (DrawY < BallY + Ball_Size + 30 )) begin 
									coin2 <= 0;
							end
							
							if (ball_on == 11 && (char_signal == 2'd0 || char_signal == 2'd1) && (DrawY < BallY + Ball_Size + 30 )) begin 
									coin3 <= 0;
							end
					end
					
					//collision on top of block 
					if ((DrawX + baseX >= BallX) && (DrawX + baseX < BallX + Ball_Size) && (DrawY < BallY)) begin //pixel == ontop
					
							if ( ( (ball_on == 2) || (ball_on == 8) ||
								(char_signal == 2'd0 && ball_on == 3) || (char_signal == 2'd1 && ball_on == 1))
									&& (DrawY > store_smallest_ceiling))  begin 
									store_smallest_ceiling <= DrawY;
									
							end
							
							if ((ball_on == 8 && (char_signal == 2'd0 || char_signal == 2'd1))  && 
								((DrawY < BallY)  && (DrawY > BallY - 2))  && 
								(DrawX + baseX) >= 224 && (DrawX + baseX) < 288 ) begin 
									
									coin1 <= 1;
							end
							
							if ((ball_on == 8 && (char_signal == 2'd0 || char_signal == 2'd1))  && 
								((DrawY < BallY)  && (DrawY > BallY - 2))  && 
								(DrawX + baseX) >= 2176 && (DrawX + baseX) < 2208) begin 
									
									coin2 <= 1;
							end
							
							if ((ball_on == 8 && (char_signal == 2'd0 || char_signal == 2'd1))  && 
								((DrawY < BallY)  && (DrawY > BallY - 2))  && 
								(DrawX + baseX) >= 3200 && (DrawX + baseX) < 3232) begin 
									
									coin3 <= 1;
							end
							
							if ((ball_on == 4 && (char_signal == 2'd0 || char_signal == 2'd1))  && 
								((DrawY < BallY)  && (DrawY > BallY - 2)) ) begin 
									
									fall <= 1;
							end
							
							if ( ((ball_on == 1 || ball_on == 3) && (char_signal == 2'd2))  &&  //if m or l collide with top of goomba
								(DrawY > BallY - 20))  begin 
									//we want mario and luigi to have no motion for a second
									//set their ceiling to goomba
									//goomba falls here
									fall <= 1;
							end
								
							
					end
					
					//collision with the right side of the block 
					if ((DrawY >= BallY) && (DrawY < BallY + Ball_Size) && (DrawX + baseX > BallX + 32)) begin 
					
							if ( ( (ball_on == 2) || (ball_on == 8) || (char_signal == 2'd0 && ball_on == 3) 
									|| (char_signal == 2'd1 && ball_on == 1)) && (DrawX + baseX < store_smallest_right)) begin 
									store_smallest_right <= DrawX + baseX;
							end
								
							
							if ((ball_on == 4 && (char_signal == 2'd0 || char_signal == 2'd1))  && 
								((DrawX + baseX < BallX + 32)  && (DrawX + baseX > BallX + 30)) ) begin 
									
									fall <= 1;
							end
							
							if (ball_on == 9 &&  (char_signal == 2'd0 || char_signal == 2'd1) && (DrawX + baseX < BallX + Ball_Size + 30 )) begin 
									coin1 <= 0;
							end
							
							if (ball_on == 10 &&  (char_signal == 2'd0 || char_signal == 2'd1) && (DrawX + baseX < BallX + Ball_Size + 30 )) begin 
									coin2 <= 0;
							end
							
							if (ball_on == 11 &&  (char_signal == 2'd0 || char_signal == 2'd1) && (DrawX + baseX < BallX + Ball_Size + 30 )) begin 
									coin3 <= 0;
							end
						
							
					end
					
					
					
					//collision with the left side of the block 
					if ((DrawY >= BallY) && (DrawY < BallY + Ball_Size) && (DrawX + baseX< BallX)) begin 
					
							if ( ( (ball_on == 2) || (ball_on == 8) || (char_signal == 2'd0 && ball_on == 3) || (char_signal == 2'd1 && ball_on == 1) )
									&& (DrawX > store_biggest_left))  begin 
									store_biggest_left <= DrawX;
							end
							
							if ((ball_on == 4 && (char_signal == 2'd0 || char_signal == 2'd1))  && 
								((DrawX + baseX < BallX )  && (DrawX + baseX > BallX - 2)) ) begin 
									
									fall <= 1;
							end
							
							if (ball_on == 9  && (char_signal == 2'd0 || char_signal == 2'd1) && (DrawX + baseX > BallX - 5 ) ) begin 
									coin1 <= 0;
							end
							
							if (ball_on == 10  && (char_signal == 2'd0 || char_signal == 2'd1) && (DrawX + baseX > BallX - 5 ) ) begin 
									coin2 <= 0;
							end
							
							if (ball_on == 11  && (char_signal == 2'd0 || char_signal == 2'd1) && (DrawX + baseX > BallX - 5 ) ) begin 
									coin3 <= 0;
							end
							
					end
					
					
					//logic to reset the register
					new1 <= frame_Clk;
					new2 <= new1;
					
					if ( new1 == 1 && new2 == 0 ) begin 
							
							
							if (BallY >=  600) begin 
								fall <= 0;
							end
							
							store_tallest_ground <= 21'd999;
							store_smallest_ceiling <= 21'd0;
							store_smallest_right <= 21'd5000;
							store_biggest_left <= 21'd0;
							
					end
					
				end
				
		end
		
		
		
endmodule



