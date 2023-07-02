module conv1d (clk, rst, A, kern, out);

parameter bw = 8;
parameter rows = 8;
parameter bw_psum = 2*bw + $clogb2(rows);

input clk, rst;
input [rows*bw-1:0] A;
input [rows*bw-1:0] kern;
output [bw_psum-1:0] out;

wire [2*bw*rows-1:0] partial;

genvar i;
generate
for(i=0; i<rows; i = i+1) begin
  assign partial[(i+1)*2*bw-1 : (i)*2*bw] = {{(bw){A[bw*(i+1)-1]}}, A[bw*(i+1)-1: bw*i]} * {{(bw){kern[bw*(i+1)-1}}, kern[bw*(i+1)-1: bw*i]};
end
endgenerate

reg [bw_psum-1:0] total_out;
reg [bw_psum-1:0] psum_tree1;
reg [bw_psum-1:0] psum_tree2;

assign out = total_out;

integer q;

always @(posedge clk or posedge rst) begin
  if(rst)
    psum_tree1 = 0;
  else begin
    psum_tree1 = {{(3){partial[2*bw-1]}}, partial[2*bw-1:0]};
    for(q=1; q<rows/2; q+=1) begin
      psum_tree1 += {{(3){partial[2*bw*(q+1)-1]}}, partial[2*bw*q +: 2*bw]};
    end
  end
end

always @(posedge clk or posedge rst) begin
  if(rst)
    psum_tree2 = 0;
  else begin
    psum_tree2 = {{(3){partial[2*bw*rows/2-1]}},partial[ (2*bw*rows/2)-1: 2*bw*(rows/2 - 1)]};
    for(q=rows/2+1; q<rows; q+=1) begin
      psum_tree2 += {{(3){partial[2*bw*(q+1)-1]}}, partial[2*bw*q +: 2*bw]};
    end
  end
end


always @(posedge clk or posedge rst) begin
	if(rst) 
		total_out <= 0;
		else
			total_out <= psum_tree1 + psum_tree2;
end

endmodule
