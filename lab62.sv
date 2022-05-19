//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab62 (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




logic Reset_h, vssig, blank, sync, VGA_Clk;

//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig;
	logic [20:0] ballxsig_m, ballysig_m, ballsizesig_m;
	logic [7:0] Red, Blue, Green;
	logic [31:0] keycode;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (points_m[5:4], HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (points_m[3:0], HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (points_l[5:4], HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (points_l[3:0], HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red[7:4];
	assign VGA_B = Blue[7:4];
	assign VGA_G = Green[7:4];
	
	//Collision values for mario 
	logic signed [20:0] Ground_Y_m, Ceiling_Y_m, Left_X_m, Right_X_m;
	logic [10:0] ball_on;
	logic [20:0] Ball_X_Start_m=100;  // Center position on the X axis
   logic [20:0] Ball_Y_Start_m=352;
	logic coin1_m, coin2_m, coin3_m;
	
	//values for luigi 
	logic signed [20:0] Ground_Y_l, Ceiling_Y_l, Left_X_l, Right_X_l;
	logic [20:0] ballxsig_l, ballysig_l, ballsizesig_l;
	logic [20:0] Ball_X_Start_l=150;  // Center position on the X axis
   logic [20:0] Ball_Y_Start_l=352;
	logic coin1_l, coin2_l, coin3_l;
	
	//values for goomba 
	logic signed [20:0] Ground_Y_g, Ceiling_Y_g, Left_X_g, Right_X_g;
	logic [20:0] GoombaX, GoombaY;
	logic [20:0] StartX = 700;
   logic [20:0] StartY = 100;

	
	logic scroll_m, scroll_l;
	logic signed [20:0] baseX;
	
	
	lab62_soc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, LEDR}),
		.keycode_export(keycode),
		
	 );


//instantiate a vga_controller, ball, and color_mapper here with the ports.

logic fall;

vga_controller vga0 ( .Clk(MAX10_CLK1_50), .Reset(Reset_h), .hs(VGA_HS), .vs(VGA_VS), .pixel_clk(VGA_Clk), 
							.blank(blank), .sync(sync), .DrawX(drawxsig), .DrawY(drawysig));
							

color_mapper cm0(		.Clk(MAX10_CLK1_50), .frame_clk(VGA_VS), .Reset(Reset_h) , .scroll(scroll_m || scroll_l),
							.BallX(ballxsig_m), .BallY(ballysig_m), .LuigiX(ballxsig_l), .LuigiY(ballysig_l),
							.GoombaX(GoombaX), .GoombaY(GoombaY), 
							.DrawX(drawxsig), .DrawY(drawysig), .Ball_size_m(ballsizesig_m), .Ball_size_l(ballsizesig_l),
							 .blank(blank), .coin1(coin1_m || coin1_l), .coin2(coin2_m || coin2_l), .coin3(coin3_m || coin3_l),
							 .ball_on(ball_on),
                       .Red(Red), .Green(Green), .Blue(Blue),
							  .baseX(baseX));		
						
						
character mario0 (.Reset(Reset_h), .frame_clk(VGA_VS), .char_signal(2'b0),
					.keycode(keycode), .Ball_X_Start(Ball_X_Start_m), .Ball_Y_Start(Ball_Y_Start_m),
					.Ground_Y(Ground_Y_m), .Ceiling_Y(Ceiling_Y_m), .Right_X(Right_X_m), .Left_X(Left_X_m), 
               .BallX(ballxsig_m), .BallY(ballysig_m), .BallS(ballsizesig_m),
					.scroll(scroll_m));			
							
							
collision c0_mario (		.VGA_Clk(VGA_Clk), .frame_Clk(VGA_VS), .Reset(Reset_h), .char_signal(2'b0),
						.ball_on(ball_on),
						.BallY(ballysig_m), .BallX(ballxsig_m), .Ball_Size(ballsizesig_m),
						.DrawX(drawxsig), .DrawY(drawysig), .baseX(baseX),
						.Ground_Y(Ground_Y_m), .Ceiling_Y(Ceiling_Y_m), .Right_X(Right_X_m), .Left_X(Left_X_m), .fall(fall),
						.coin1(coin1_m), .coin2(coin2_m), .coin3(coin3_m));

						
character luigi0 (.Reset(Reset_h), .frame_clk(VGA_VS), .char_signal(2'b1),
					.keycode(keycode), .Ball_X_Start(Ball_X_Start_l), .Ball_Y_Start(Ball_Y_Start_l),
					.Ground_Y(Ground_Y_l), .Ceiling_Y(Ceiling_Y_l), .Right_X(Right_X_l), .Left_X(Left_X_l), 
               .BallX(ballxsig_l), .BallY(ballysig_l), .BallS(ballsizesig_l),
					.scroll(scroll_l));
					
					
collision c0_luigi (		.VGA_Clk(VGA_Clk), .frame_Clk(VGA_VS), .Reset(Reset_h), .char_signal(2'b1),
						.ball_on(ball_on),
						.BallY(ballysig_l), .BallX(ballxsig_l), .Ball_Size(ballsizesig_l),
						.DrawX(drawxsig), .DrawY(drawysig), .baseX(baseX),
						.Ground_Y(Ground_Y_l), .Ceiling_Y(Ceiling_Y_l), .Right_X(Right_X_l), .Left_X(Left_X_l),
						.coin1(coin1_l), .coin2(coin2_l), .coin3(coin3_l));
						

goomba goomba0 (	.Reset(Reset_h), .frame_clk(VGA_VS), .scroll(scroll_m || scroll_l),
						.StartX(StartX), .StartY(StartY), .baseX(baseX),
						.Ground_Y(Ground_Y_g), .Ceiling_Y(Ceiling_Y_g), .Right_X(Right_X_g), .Left_X(Left_X_g),
						.GoombaX(GoombaX), .GoombaY(GoombaY));
						
						
collision c0_goomba (		.VGA_Clk(VGA_Clk), .frame_Clk(VGA_VS), .Reset(Reset_h), .char_signal(2'd2),
						.ball_on(ball_on),
						.BallY(GoombaY), .BallX(GoombaX), .Ball_Size(ballsizesig_l), //size is same?
						.DrawX(drawxsig), .DrawY(drawysig), .baseX(baseX),
						.Ground_Y(Ground_Y_g), .Ceiling_Y(Ceiling_Y_g), .Right_X(Right_X_g), .Left_X(Left_X_g)	);



endmodule
