//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper (  input Clk, frame_clk, Reset, scroll,
								input [20:0] BallX, BallY, LuigiX, LuigiY, Ball_size_m, Ball_size_l, GoombaX, GoombaY,
								input [9:0] DrawX, DrawY,
							  input 	blank, 
							  input  coin1, coin2, coin3,
							  output logic [10:0]  ball_on,
                       output logic [7:0]  Red, Green, Blue, 
							  output logic signed [20:0] baseX);
    
	 //logic signed [20:0] baseX = 13'd0;//draw everything in relation to this (for scrolling)
	 
	 logic [9:0] titleY = 10'd50;
	 logic [9:0] titleX = 10'd192;
	 
	 logic [9:0] coin1Y = 10'd288;
	 logic [9:0] coin1X = 10'd224;
	 
	 logic [9:0] coin2Y = 10'd256;
	 logic [20:0] coin2X = 21'd2176;
	 
	 logic [9:0] coin3Y = 10'd288;
	 logic [20:0] coin3X = 21'd3200;
	 
	 logic [20:0] flagX = 21'd4320;
	 logic [9:0] flagY = 10'd264;
	 
	 logic [20:0] castleX = 21'd4363;
	 logic [9:0] castleY = 10'd296;
	 
	 logic [9:0] endY = 10'd246;
	 logic [9:0] endX = 10'd233;
	 
	 logic [23:0] luigi_pixel_color;
	 logic [23:0] mario_pixel_color;
	 logic [23:0] tile_pixel_color;
	 logic [23:0] title_pixel_color;
	 logic [23:0] end_pixel_color;
	 logic [23:0] goomba_pixel_color;
	 logic [23:0] flag_pixel_color;
	 logic [23:0] castle_pixel_color;
	 logic [23:0] coinHolder_pixel_color;
	 logic [23:0] coin_pixel_color;
	 logic [23:0] coin1_pixel_color;
	 logic [23:0] coin2_pixel_color;
	 
	 always_ff @ (posedge frame_clk or posedge Reset)
	 begin 
		if (Reset) begin 
			baseX <= 21'b0;
			coin1Y <= 288;
			coin2Y <= 256;
			coin3Y <= 288;
		end
		
		else begin 
			if (scroll && (DrawX + baseX <= 3880)) begin
				baseX <= baseX + 1;
			end
			
			//reset position of coins after they are touched
			
			if (coin1 == 0) begin 
				coin1Y <= 288;
			end
			
			if (coin2 == 0) begin 
				coin2Y <= 256;
			end
			
			if (coin3 == 0) begin 
				coin3Y <= 288;
			end
			
			if (coin1 && (coin1Y >= 256)) begin 
				coin1Y <= coin1Y - 1;
			end
			
			if (coin2 && (coin2Y >= 224)) begin 
				coin2Y <= coin2Y - 1;
			end
			
			if (coin3 && (coin3Y >= 256)) begin 
				coin3Y <= coin3Y - 1;
			end
		
		end
	
		
	 end
	 
    always_comb
    begin:Ball_on_proc
	 // 0 = background
	 // 1 = Mario
	 // 2 = platforms/ground
	 // 3 = luigi
	 // 4 = goomba
	 // 5 = title
	 // 6 = flag
	 // 7 = castle
	 // 8 = coin holder
	 
        if ( (DrawX + baseX > BallX ) &&
       (DrawX + baseX < BallX + Ball_size_m) &&
       (DrawY > BallY ) &&
       (DrawY < BallY + Ball_size_m) ) 
            ball_on = 10'd1;
			
				
		  //ground & platforms
		  else if ( (DrawY >= 416 && DrawX + baseX < 320) || 
						(DrawY >= 416 && (DrawX + baseX >= 384 && DrawX + baseX < 1280)) ||
						(DrawY >= 416 && (DrawX + baseX >= 1440 && DrawX + baseX < 2080)) ||
						(DrawY >= 416 && (DrawX + baseX >= 2144 && DrawX + baseX < 3040)) ||
						(DrawY >= 416 && (DrawX + baseX >= 3104 && DrawX + baseX < 3584)) ||
						(DrawY >= 416 && (DrawX + baseX >= 3648)) ||
						/*(DrawY <= 32)|| */
		  
		  //platforms below here
						((DrawY >= 288 && DrawY <= 320) && (DrawX + baseX >= 64 && DrawX + baseX < 224)) ||
						((DrawY >= 288 && DrawY <= 320) && (DrawX + baseX >= 416 && DrawX + baseX < 576)) ||
						((DrawY >= 320 && DrawY <= 352) && (DrawX + baseX >= 704 && DrawX + baseX < 800)) ||
						((DrawY >= 256 && DrawY <= 288) && (DrawX + baseX >= 864 && DrawX + baseX < 928)) ||
						((DrawY >= 320 && DrawY <= 352) && (DrawX + baseX >= 960 && DrawX + baseX < 1088)) ||
						
						((DrawY >= 320 && DrawY <= 352) && (DrawX + baseX >= 1216 && DrawX + baseX < 1280)) ||
						((DrawY >= 320 && DrawY <= 352) && (DrawX + baseX >= 1344 && DrawX + baseX < 1408)) ||
						((DrawY >= 320 && DrawY <= 352) && (DrawX + baseX >= 1472 && DrawX + baseX < 1536)) ||
						
						((DrawY >= 320 && DrawY <= 352) && (DrawX + baseX >= 1760 && DrawX + baseX < 1824)) ||
						((DrawY >= 256 && DrawY <= 288) && (DrawX + baseX >= 1856 && DrawX + baseX < 1920)) ||
						((DrawY >= 192 && DrawY <= 224) && (DrawX + baseX >= 1952 && DrawX + baseX < 2016)) ||
						
						((DrawY >= 256 && DrawY <= 288) && (DrawX + baseX >= 2080 && DrawX + baseX < 2176)) ||
						
						((DrawY >= 192 && DrawY <= 224) && (DrawX + baseX >= 2272 && DrawX + baseX < 2336)) ||
						((DrawY >= 256 && DrawY <= 288) && (DrawX + baseX >= 2368 && DrawX + baseX < 2432)) ||
						((DrawY >= 320 && DrawY <= 352) && (DrawX + baseX >= 2464 && DrawX + baseX < 2528)) ||
					//here now
					
						((DrawY >= 288 && DrawY <= 320) && (DrawX + baseX >= 2720 && DrawX + baseX < 2848)) ||
						
						((DrawY >= 224 && DrawY <= 256) && (DrawX + baseX >= 2912 && DrawX + baseX < 2976)) ||
						((DrawY >= 192 && DrawY <= 224) && (DrawX + baseX >= 3008 && DrawX + baseX < 3072)) ||
						
						((DrawY >= 288 && DrawY <= 320) && (DrawX + baseX >= 3232 && DrawX + baseX < 3360)) ||
						
						((DrawY >= 224 && DrawY <= 256) && (DrawX + baseX >= 3424 && DrawX + baseX < 3488)) ||
						
						((DrawY >= 288 && DrawY <= 320) && (DrawX + baseX >= 3520 && DrawX + baseX < 3584)) ||
						((DrawY >= 288 && DrawY <= 320) && (DrawX + baseX >= 3648 && DrawX + baseX < 3712)) ||
						((DrawY >= 288 && DrawY <= 320) && (DrawX + baseX >= 3776 && DrawX + baseX < 3840)) ||
						
						((DrawY >= 256 && DrawY <= 288) && (DrawX + baseX >= 3904 && DrawX + baseX < 4032)) ) 
				ball_on = 10'd2;
				
		
		  else if ( (DrawX + baseX > LuigiX ) &&
       (DrawX + baseX < LuigiX + Ball_size_l) &&
       (DrawY > LuigiY ) &&
       (DrawY < LuigiY + Ball_size_l) ) 
            ball_on = 10'd3;
	
			
		  //hard code goomba to get dying logic down 
		  else if ( ((DrawX + baseX >= GoombaX ) && (DrawX + baseX < GoombaX + Ball_size_m) && (DrawY >= GoombaY ) && (DrawY < GoombaY + Ball_size_m))) 
            ball_on = 10'd4;
			
		  //title sprite
		  else if (( ((DrawX + baseX) >= 192 && (DrawX + baseX) <= 448) && (DrawY >= 50 && DrawY < 190) )) 
				ball_on = 10'd5;

				
			//flag sprite
			else if (( ((DrawX + baseX) >= flagX && (DrawX + baseX) < flagX + 28) && (DrawY >= flagY && DrawY < flagY + 152) )) 
				ball_on = 10'd6;
				
			//castle sprite
			else if (( ((DrawX + baseX) >= castleX && (DrawX + baseX) < castleX + 122) && (DrawY >= castleY && DrawY < castleY + 120) )) 
				ball_on = 10'd7;
				
			//coin holder sprite
			else if (( ((DrawX + baseX) >= 224 && (DrawX + baseX) < 256) && (DrawY >= 288 && DrawY < 320) ) ||
							((DrawY >= 256 && DrawY <= 288) && (DrawX + baseX >= 2176 && DrawX + baseX < 2208)) ||
							((DrawY >= 288 && DrawY <= 320) && (DrawX + baseX >= 3200 && DrawX + baseX < 3332)) )
				ball_on = 10'd8;
			
			//coin
			else if (((DrawX + baseX) >= coin1X && (DrawX + baseX) < coin1X + 32) && (DrawY >= coin1Y && DrawY < coin1Y + 32)) begin 
				ball_on = 9;
			end
			
			else if (((DrawX + baseX) >= coin2X && (DrawX + baseX) < coin2X + 32) && (DrawY >= coin2Y && DrawY < coin2Y + 32) ) begin 
				ball_on = 10;
			end
			
			else if (((DrawX + baseX) >= coin3X && (DrawX + baseX) < coin3X + 32) && (DrawY >= coin3Y && DrawY < coin3Y + 32) ) begin 
				ball_on = 11;
			end
			
        else
            ball_on = 10'd0;
		
     end 
       
    always_comb
    begin:RGB_Display
			if (blank) begin //active low
			
				if ((ball_on == 10'd1)) //draw the mario 
				begin 
						if ( mario_pixel_color == 24'hFF00EA) begin 
							Red = 8'h19; 
							Green = 8'hb2;
							Blue = 8'hff;
						end
						
						else begin
							Red = mario_pixel_color[23:16];
							Green = mario_pixel_color[15:8];
							Blue = mario_pixel_color[7:0];
						end
				end   
	
				
				else if (ball_on == 10'd2) 	//draw ground & platforms
				begin 
						if ( tile_pixel_color == 24'hFF00EA ) begin 
							Red = 8'h19; 
							Green = 8'hb2;
							Blue = 8'hff;
						end
						
						else begin
							Red = tile_pixel_color[23:16];
							Green = tile_pixel_color[15:8];
							Blue = tile_pixel_color[7:0];
						end 
						
						//Red = 8'h99; 
						//Green = 8'h4d;
						//Blue = 8'h00;
				end
				
				else if (ball_on == 10'd3) 	//draw luigi 
				begin 
						if ( luigi_pixel_color == 24'hFF00EA ) begin 
							Red = 8'h19; 
							Green = 8'hb2;
							Blue = 8'hff;
						end
						
						else begin
							Red = luigi_pixel_color[23:16];
							Green = luigi_pixel_color[15:8];
							Blue = luigi_pixel_color[7:0];
						end
				end
				
				else if (ball_on == 10'd4) 	//draw goomba 
				begin 
						
						if ( goomba_pixel_color == 24'hFF00EA) begin 
							Red = 8'h19; 
							Green = 8'hb2;
							Blue = 8'hff;
						end
							
						else begin
							Red = goomba_pixel_color[23:16];
							Green = goomba_pixel_color[15:8];
							Blue = goomba_pixel_color[7:0];
						end
							
				end
				
				
				else if (ball_on == 10'd5) 	//draw title sprite 
				begin 
						if ( title_pixel_color == 24'hFF00EA ) begin 
							Red = 8'h19; 
							Green = 8'hb2;
							Blue = 8'hff;
						end
						
						else begin
							Red = title_pixel_color[23:16];
							Green = title_pixel_color[15:8];
							Blue = title_pixel_color[7:0];
						end
						
						
				end
			
				else if (ball_on == 10'd6) 	//draw flag sprite 
				begin 
						if ( flag_pixel_color == 24'hFF00EA ) begin 
							Red = 8'h19; 
							Green = 8'hb2;
							Blue = 8'hff;
						end
						
						else begin
							Red = flag_pixel_color[23:16];
							Green = flag_pixel_color[15:8];
							Blue = flag_pixel_color[7:0];
						end
						
						
				end
				
				else if (ball_on == 10'd7) 	//draw castle sprite 
				begin 
						if ( castle_pixel_color == 24'hCB7D6E ) begin 
							Red = 8'h19; 
							Green = 8'hb2;
							Blue = 8'hff;
						end
						
						else begin
							Red = castle_pixel_color[23:16];
							Green = castle_pixel_color[15:8];
							Blue = castle_pixel_color[7:0];
						end
						
						
				end
				
				else if (ball_on == 10'd8) 	//draw ccoin holder
				begin 
						if ( coinHolder_pixel_color == 24'hFF00EA ) begin 
							Red = 8'h19; 
							Green = 8'hb2;
							Blue = 8'hff;
						end
						
						else begin
							Red = coinHolder_pixel_color[23:16];
							Green = coinHolder_pixel_color[15:8];
							Blue = coinHolder_pixel_color[7:0];
						end
						
						
				end
				
				else if (ball_on == 9) begin //draw coin
				
						if ( coin_pixel_color == 24'hFF00EA ) begin 
							Red = 8'h19; 
							Green = 8'hb2;
							Blue = 8'hff;
						end
						
						else begin
							Red = coin_pixel_color[23:16];
							Green = coin_pixel_color[15:8];
							Blue = coin_pixel_color[7:0];
						end
				
				end
				
				else if (ball_on == 10) begin //draw coin
				
						if ( coin1_pixel_color == 24'hFF00EA ) begin 
							Red = 8'h19; 
							Green = 8'hb2;
							Blue = 8'hff;
						end
						
						else begin
							Red = coin1_pixel_color[23:16];
							Green = coin1_pixel_color[15:8];
							Blue = coin1_pixel_color[7:0];
						end
				
				end
				
				else if (ball_on == 11) begin //draw coin
				
						if ( coin2_pixel_color == 24'hFF00EA ) begin 
							Red = 8'h19; 
							Green = 8'hb2;
							Blue = 8'hff;
						end
						
						else begin
							Red = coin2_pixel_color[23:16];
							Green = coin2_pixel_color[15:8];
							Blue = coin2_pixel_color[7:0];
						end
				
				end
				
				else //draw backround
				begin 
						Red = 8'h19; 
						Green = 8'hb2;
						Blue = 8'hff;
						//Green = 8'h00;
						//Blue = 8'h7f - DrawX[9:3];
				end  
			end
			
			else begin 
				Red = 8'h00;
				Green = 8'h00;
				Blue = 8'h00;
			end
    end 
	 
logic [20:0] add;

assign add = (DrawX + baseX);



frameRAM_luigi luigi0 ( .read_address((DrawY - LuigiY)*32 + (DrawX + baseX - LuigiX)), .Clk(Clk), .data_Out(luigi_pixel_color));
frameRAM_mario mario0 ( .read_address((DrawY - BallY)*32 + (DrawX + baseX - BallX)), .Clk(Clk), .data_Out(mario_pixel_color));
frameRAM_tile tile0 ( .read_address((DrawY[4:0]*32) + add[4:0]), .Clk(Clk), .data_Out(tile_pixel_color));
frameRAM_title title0 ( .read_address((DrawY - titleY)*256 + (DrawX + baseX - titleX)), .Clk(Clk), .data_Out(title_pixel_color));
//frameRAM_end end0 ( .read_address((DrawY - endY)*307 + (DrawX + baseX - endX)), .Clk(Clk), .data_Out(end_pixel_color));
frameRAM_goomba goomba0 ( .read_address((DrawY - GoombaY)*32 + (DrawX + baseX - GoombaX)), .Clk(Clk), .data_Out(goomba_pixel_color));
frameRAM_flag flag0 ( .read_address((DrawY - flagY)*28 + (DrawX + baseX - flagX)), .Clk(Clk), .data_Out(flag_pixel_color));
frameRAM_castle castle0( .read_address((DrawY - castleY)*122 + (DrawX + baseX - castleX)), .Clk(Clk), .data_Out(castle_pixel_color));
frameRAM_coinHolder  coin_h( .read_address(DrawY[4:0]*32 + add[4:0]), .Clk(Clk), .data_Out(coinHolder_pixel_color));
frameRAM_coin  coin_0( .read_address((DrawY - coin1Y)*32 + (DrawX + baseX - coin1X)), .Clk(Clk), .data_Out(coin_pixel_color));
frameRAM_coin  coin_1( .read_address((DrawY - coin2Y)*32 + (DrawX + baseX - coin2X)), .Clk(Clk), .data_Out(coin1_pixel_color));
frameRAM_coin  coin_2( .read_address((DrawY - coin3Y)*32 + (DrawX + baseX - coin3X)), .Clk(Clk), .data_Out(coin2_pixel_color));

endmodule

