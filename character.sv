//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  character ( input logic Reset, frame_clk, 
					input logic [1:0] char_signal, //char_signal = 0 if mario and 1 if luigi
					input logic [31:0]  keycode, 
					input logic [20:0] Ball_X_Start, Ball_Y_Start, 
					input logic signed [20:0] Ground_Y, Ceiling_Y, Left_X, Right_X,
               output logic signed [20:0] BallX, BallY, BallS,
					output logic scroll);
    
    logic signed [20:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Size, Ball_Y_Motion;
	 
	 logic jump_signal, left_signal, right_signal;
	 
    assign Ball_Size = 32;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge frame_clk or posedge Reset)
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
				
				Ball_Y_Pos <= Ball_Y_Start;
				Ball_X_Pos <= Ball_X_Start;
				
				jump_signal = 1'b0;
				scroll = 1'b0;
        end
           
        else begin 
				 jump_signal <= 0;
				 left_signal <= 0;
				 right_signal <= 0;
				 
				if (char_signal == 2'b0) begin 
				
					if ( keycode[15:8] == 8'h04 || keycode[7:0] == 8'h04
							|| keycode[23:16] == 8'h04 || keycode[31:24] == 8'h04) //A
					begin 
							left_signal <= 1;
							scroll = 1;
					end 
					
					if (keycode[15:8] == 8'h07 || keycode[7:0] == 8'h07
							|| keycode[23:16] == 8'h07 || keycode[31:24] == 8'h07) //D
					begin
							right_signal <= 1;
							scroll = 1;
					end
					
					if (keycode[15:8] == 8'h16 || keycode[7:0] == 8'h16
							|| keycode[23:16] == 8'h16 || keycode[31:24] == 8'h16) //S 
					begin 
							//duck here
					end 
					
					if (keycode[15:8] == 8'h1A || keycode[7:0] == 8'h1A
							|| keycode[23:16] == 8'h1A || keycode[31:24] == 8'h1A) //W
					begin
							jump_signal <= 1;
							scroll = 1;
					end
					
				end
				
				 
				else if (char_signal == 2'b1) begin 
				
					if ( keycode[15:8] == 8'h50 || keycode[7:0] == 8'h50
							|| keycode[23:16] == 8'h50 || keycode[31:24] == 8'h50) // LEFT arrow
					begin 
							left_signal <= 1;
							scroll = 1;
					end 
					
					if (keycode[15:8] == 8'h4f || keycode[7:0] == 8'h4f
							|| keycode[23:16] == 8'h4f || keycode[31:24] == 8'h4f) //RIGHT arrow
					begin
							right_signal <= 1;
							scroll = 1;
					end
					
					if (keycode[15:8] == 8'h51 || keycode[7:0] == 8'h51
							|| keycode[23:16] == 8'h51 || keycode[31:24] == 8'h51) //DOWN arrow 
					begin 
							//duck here
					end 
					
					if (keycode[15:8] == 8'h52 || keycode[7:0] == 8'h52
							|| keycode[23:16] == 8'h52 || keycode[31:24] == 8'h52) // UP arrow
					begin
							jump_signal <= 1;
							scroll = 1;
					end
					
				end
				//update position
				
				if ((Ball_Y_Pos  + Ball_Y_Motion) >= Ground_Y-1 ) begin //character will pass ground
					Ball_Y_Pos <= Ground_Y-1;
				end
					
				else if ((Ball_Y_Pos  + Ball_Y_Motion) <= Ceiling_Y ) begin //character will go into platform
					Ball_Y_Pos <= Ceiling_Y;
				end
				
				else begin
					Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // wont pass gound
				end
				

				Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
			
		end 
		
    end
       

    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;
	 
	 jump jump_mario(	.Clk(frame_clk), .Reset(Reset), .Run(jump_signal), .Left(left_signal), .Right(right_signal),
						.BallY(BallY), .BallX(BallX), 
						.Ground_Y(Ground_Y), .Ceiling_Y(Ceiling_Y), .Right_X(Right_X), .Left_X(Left_X),
						.Ball_Y_Motion(Ball_Y_Motion), .Ball_X_Motion(Ball_X_Motion));
    

endmodule
