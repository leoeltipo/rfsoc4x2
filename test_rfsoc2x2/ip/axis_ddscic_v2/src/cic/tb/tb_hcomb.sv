module tb;

parameter NCH= 5;
parameter B  = 5;

reg				rstn;
reg 			clk;
reg  [B-1:0]	din;
reg				din_valid;
wire [B-1:0]	dout;
wire			dout_valid;

hcomb
    #(
        .NCH(NCH),
        .B	(B	)
    )
    DUT
	( 
		.rstn		,
        .clk   		,
        .din    	,
		.din_valid	,
        .dout		,
		.dout_valid
    );

initial begin
	rstn		<= 0;
	din			<= 0;
	din_valid	<= 0;

	#300;

	@(posedge clk);
	rstn	<= 1;

	#200;

	for (int i=0; i<1000; i = i+1) begin
		for (int j=0; j<11; j=j+1) begin
			@(posedge clk);
			din			<= $random;
			din_valid 	<= 1;
		end
		@(posedge clk);
		din			<= $random;
		din_valid 	<= 0;
		@(posedge clk);
		din			<= $random;
		din_valid 	<= 0;
		@(posedge clk);
		din			<= $random;
		din_valid 	<= 0;
	end
end

always begin
	clk <= 0;
	#5;
	clk <= 1;
	#5;
end

endmodule

