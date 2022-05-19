module goomba ( input logic Reset, frame_clk, scroll,
						input logic signed [20:0] StartX, StartY, baseX,
						input logic signed [20:0] Ground_Y, Ceiling_Y, Left_X, Right_X,
						output logic signed [20:0] GoombaX, GoombaY);
						
//create the gommba and send the X,Y cords here?
	logic signed [20:0] Goomba_X_Motion, Goomba_Y_Motion;
	
	
	always_ff @ (posedge frame_clk or posedge Reset) begin 
	
		if (Reset) begin 
			GoombaX <= StartX; //this will put it at the edge of the screen 
			GoombaY <= StartY;
		end
		
		else begin 
		
				if ((GoombaY  + Goomba_Y_Motion) >= Ground_Y-1 ) begin //character will pass ground
					GoombaY <= Ground_Y-1;
				end
				/*	
				else if ((GoombaY  + Goomba_Y_Motion) <= Ceiling_Y ) begin //character will go into platform
					GoombaY <= Ceiling_Y;
				end
				*/
				else if (GoombaX <= 0 + baseX || GoombaY >= 480) begin 
					GoombaY <= 100;
				end
				
				else begin
					GoombaY <= (GoombaY + Goomba_Y_Motion);  // wont pass gound
				end
				 
				 
				 
				
				if (GoombaX <= 0 + baseX || GoombaY >= 480) begin 
					GoombaX <= 700 + baseX;
					//GoombaY <= 100;
				end
				
				else begin 
					GoombaX <= (GoombaX + Goomba_X_Motion);
				end
		end
	
	end
	
	
	
jump jump_goomba(	.Clk(frame_clk), .Reset(Reset), .Run(1'b0), .Left(scroll), .Right(1'b0),
						.BallY(GoombaY), .BallX(GoombaX), 
						.Ground_Y(Ground_Y), .Ceiling_Y(Ceiling_Y), .Right_X(Right_X), .Left_X(Left_X),
						.Ball_Y_Motion(Goomba_Y_Motion), .Ball_X_Motion(Goomba_X_Motion));
    
	
endmodule  